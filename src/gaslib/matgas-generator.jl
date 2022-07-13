using JSON
using GasModels
using Base.Filesystem
using KNITRO
using Ipopt 
using JuMP

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer)
knitro = JuMP.optimizer_with_attributes(KNITRO.Optimizer)

get_simulation_params(; T::Float64 = 288.70599999999996) = 
    Dict{String,Any}(
    "Temperature (K):" => T,
    "Gas specific gravity (G):" => 0.6,
    "Specific heat capacity ratio" => 1.4,
    "units (SI = 0, standard = 1)" => 0.0
)


function generate_steady_sim_inputs_from_matgas(file::AbstractString, 
    input_folder::AbstractString, output_folder::AbstractString;
    compressor_ratio::Float64 = 1.2, control_valve_ratio::Float64 = 1.0)

    data = parse_file(input_folder * file)

    for (_, receipt) in data["receipt"]
        receipt["injection_max"] = 10000.0
    end 

    for (_, delivery) in data["delivery"]
        delivery["withdrawal_max"] = 10000.0
    end

    for (_, transfer) in data["transfer"]
        if (transfer["withdrawal_min"] < 0)
            transfer["withdrawal_min"] = -10000.0
            continue 
        end 
        if (transfer["withdrawal_max"] > 0)
            transfer["withdrawal_max"] = 10000.0 
        end
    end

    result = GasModels.run_ls(data, WPGasModel, knitro)

    GC.gc()

    (!isdir(output_folder)) && (mkdir(output_folder)) 


    network_data = Dict{String,Any}(
        "nodes" => Dict{String,Any}(), 
        "pipes" => Dict{String,Any}(), 
        "compressors" => Dict{String,Any}(),
    )

    bc = Dict{String,Any}(
        "boundary_compressor" => Dict{String,Any}(),
        "boundary_nonslack_flow" => Dict{String,Any}(),
        "boundary_pslack" => Dict{String,Any}()
    )

    withdrawal = Dict{String,Any}()

    for (i, _) in data["junction"]
        withdrawal[i] = 0.0
    end 

    for (i, receipt) in result["solution"]["receipt"]
        node = string(data["receipt"][i]["junction_id"])
        withdrawal[node] -= receipt["fg"] * data["base_flow"]
    end 

    for (i, delivery) in result["solution"]["delivery"]
        node = string(data["delivery"][i]["junction_id"])
        withdrawal[node] += delivery["fd"] * data["base_flow"]
    end 

    for (i, transfer) in result["solution"]["transfer"]
        node = string(data["transfer"][i]["junction_id"])
        withdrawal[node] += transfer["ft"] * data["base_flow"]
    end 

    withdrawal_values = [v for (k, v) in withdrawal]
    max_injection = minimum(withdrawal_values)
    nodes_with_max_injection = sort([k for (k,v) in withdrawal if v == max_injection])
    slack_node = nodes_with_max_injection[1]

    for (i, node) in data["junction"]
        network_data["nodes"][i] = Dict{String,Any}(
            "node_id" => parse(Int, i),
            "node_name" => "n" * i,
            "x_coord" => node["lat"],
            "y_coord" => node["lon"], 
            "min_pressure" => node["p_min"] * data["base_pressure"], 
            "max_pressure" => node["p_max"] * data["base_pressure"]
        )
        if node["junction_type"] == 1
            network_data["nodes"][i]["slack_bool"] = 1
            bc["boundary_pslack"][i] = 5000000
        else 
            network_data["nodes"][i]["slack_bool"] = 0
            if !(withdrawal[i] == 0)
                bc["boundary_nonslack_flow"][i] = withdrawal[i]
            end
        end
    end

    for (i, pipe) in data["pipe"]
        network_data["pipes"][i] = Dict{String,Any}(
            "pipe_id" => parse(Int, i),
            "pipe_name" => "p" * i,
            "from_node" => pipe["fr_junction"],
            "to_node" => pipe["to_junction"],
            "diameter" => pipe["diameter"] * data["base_diameter"],
            "length" => pipe["length"] * data["base_length"],
            "friction_factor" => pipe["friction_factor"],
        )
    end 

    for (i, compressor) in data["compressor"]
        network_data["compressors"][i] = Dict{String,Any}(
            "comp_id" => parse(Int, i),
            "comp_name" => "c" * i,
            "from_node" => compressor["fr_junction"],
            "to_node" => compressor["to_junction"]
        )
        bc["boundary_compressor"][i] = Dict{String,Any}(
            "control_type" => 0, "value" => result["solution"]["compressor"][i]["r"]
        )
    end 

    network_data["control_valves"] = Dict{String,Any}() 
    bc["boundary_control_valve"] = Dict{String,Any}("on" => [], "off" => [])
    for (i, cv) in get(data, "regulator", [])
        network_data["control_valves"][i] = Dict{String,Any}(
        "control_valve_id" => parse(Int, i),
        "control_valve_name" => "cv" * i,
        "from_node" => cv["fr_junction"],
        "to_node" => cv["to_junction"],
        "bypass_required" => cv["bypass_required"]
        )
        push!(bc["boundary_control_valve"]["on"], parse(Int, i))
        bc["boundary_control_valve"][i] = Dict{String,Any}(
            "control_type" => 0, "value" => control_valve_ratio
        )
    end 

    network_data["valves"] = Dict{String,Any}() 
    bc["boundary_valve"] = Dict{String,Any}("on" => [], "off" => [])
    for (i, v) in get(data, "valve", []) 
        network_data["valves"][i] = Dict{String,Any}(
            "valve_id" => parse(Int, i),
            "valve_name" => "v" * i,
            "from_node" => v["fr_junction"],
            "to_node" => v["to_junction"]
        )
        push!(bc["boundary_valve"]["on"], parse(Int, i))
    end 

    network_data["resistors"] = Dict{String,Any}()
    network_data["loss_resistors"] = Dict{String,Any}()
    network_data["short_pipes"] = Dict{String,Any}()
    for (i, res) in get(data, "resistor", [])
        network_data["resistors"][i] = Dict{String,Any}(
            "resistor_id" => parse(Int, i),
            "resistor_name" => "r" * i, 
            "from_node" => res["fr_junction"], 
            "to_node" => res["to_junction"], 
            "drag" => res["drag"], 
            "diameter" => res["diameter"]
        )
    end 

    for (i, res) in get(data, "loss_resistor", [])
        network_data["loss_resistors"][i] = Dict{String,Any}(
            "loss_resistor_id" => parse(Int, i),
            "loss_resistor_name" => "lr" * i, 
            "from_node" => res["fr_junction"], 
            "to_node" => res["to_junction"], 
            "p_loss" => res["p_loss"] * data["base_pressure"]
        )
    end 

    for (i, pipe) in get(data, "short_pipe", [])
        network_data["short_pipes"][i] = Dict{String,Any}(
            "short_pipe_id" => parse(Int, i),
            "short_pipe_name" => "sp" * i,
            "from_node" => pipe["fr_junction"],
            "to_node" => pipe["to_junction"]
        )
    end 

    open(output_folder * "params.json", "w") do f 
        JSON.print(f, Dict("simulation_params" => get_simulation_params()), 2)
    end
 
    open(output_folder * "network.json", "w") do f 
        JSON.print(f, network_data, 2)
    end

    open(output_folder * "bc.json", "w") do f 
        JSON.print(f, bc, 2)
    end

end 

generate_steady_sim_inputs_from_matgas("NA-168.m", "./data/", "./data/NA-168/")
# generate_steady_sim_inputs_from_matgas("NA-422.m", "./data/", "./data/NA-422/")