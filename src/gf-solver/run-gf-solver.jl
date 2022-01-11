using GasSteadySim
using Distributions
using DelimitedFiles
using Random 

Random.seed!(2022)

function run_gf_solver(data::Dict{String,Any}, eos::Symbol; kwargs...)
    ss = initialize_simulator(data, eos=eos)
    solver_return = run_simulator!(ss; kwargs...)
    return solver_return
end 

function perturb_compressor_ratios!(data::Dict{String,Any})
    for (_, compressor) in get(data, "boundary_compressor", [])
        compressor["value"] = rand(Uniform(1.1, 1.5))
    end 
end 

function perturb_injections!(data::Dict{String,Any})
    for (i, nonslack_flow) in get(data, "boundary_nonslack_flow", [])
        scaling = rand(Uniform(0.9, 1.1))
        data["boundary_nonslack_flow"][i] = scaling * nonslack_flow
    end 
end 

function write_results(results::Dict{Int,Any}, num_runs, output_path)
    to_write_header = ["case_name", "run_id", "eos", "solver_status", "pressure_correction",
        "num_iterations", "run_time", "feasibility"] 
    to_write = Array{Any,2}(undef, num_runs, 8)
    for i in 1:num_runs 
        result = results[i]
        case_name = result["case_name"]
        eos = result["eos"]
        status = result["solver_status"]
        pressure_correction = result["pressure_correction"]
        iter = result["num_iterations"]
        time = result["time"]
        feas = result["feasibility"]
        to_write[i, :] = [case_name, i, eos, status, pressure_correction, iter, time, feas]
    end 
    open(output_path, "w") do io
        writedlm(io, [permutedims(to_write_header); to_write], ',')
    end
end 


function paper_runs(folder::AbstractString, eos::Symbol; num_runs = 500, 
    output_folder = "./output/", output_file = "8-node-ideal.csv", case_name = "8-node") 
    data_sample = GasSteadySim._parse_data(folder)
    # julia compiling run 
    solver_return = run_gf_solver(data_sample, eos, method = :newton, show_trace = true)

    results = Dict{Int,Any}()

    for i in 1:num_runs
        results[i] = Dict{String,Any}()
        data = GasSteadySim._parse_data(folder)
        perturb_compressor_ratios!(data)
        perturb_injections!(data)
        solver_return = run_gf_solver(data, eos, method = :newton, show_trace = false)
        results[i]["solver_status"] = Int(solver_return.status)
        results[i]["pressure_correction"] = solver_return.pressure_correction_performed
        results[i]["num_iterations"] = solver_return.iterations
        results[i]["time"] = solver_return.time 
        results[i]["feasibility"] = 
            if length(solver_return.negative_flow_in_compressors) != 0
                "false" 
            elseif Int(solver_return.status) != 0
                "unknown"
            else 
                "true"
            end 
        results[i]["case_name"] = case_name
        results[i]["eos"] = string(eos)
    end 
    write_results(results, num_runs, output_folder * output_file)
    return
end 
