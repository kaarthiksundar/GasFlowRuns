using GasSteadySim
using Distributions
using DelimitedFiles
using Random 


function run_gf_solver(data::Dict{String,Any}, eos::Symbol; kwargs...)
    ss = initialize_simulator(data, eos=eos)
    solver_return = run_simulator!(ss; kwargs...)
    return solver_return
end 

function perturb_compressor_ratios!(data::Dict{String,Any})
    for (_, compressor) in get(data, "boundary_compressor", [])
        compressor["value"] = rand(Uniform(1.1, 1.4))
    end 
end 

function perturb_injections!(data::Dict{String,Any})
    for (i, nonslack_flow) in get(data, "boundary_nonslack_flow", [])
        scaling = rand(Uniform(0.75, 1.25))
        data["boundary_nonslack_flow"][i] = scaling * nonslack_flow
    end 
end 

function make_nominal_values_unity!(data::Dict{String,Any})
    data["simulation_params"]["nominal_length"] = 1.0 
    data["simulation_params"]["nominal_velocity"] = 1.0  
    data["simulation_params"]["nominal_pressure"] = 1.0 
    data["simulation_params"]["nominal_density"] = 1.0 
end 

function write_results(results::Dict{Int,Any}, num_runs, output_path)
    to_write_header = ["case_name", "run_id", "eos", "solver_status",
        "num_iterations", "run_time", "feasibility"] 
    to_write = Array{Any,2}(undef, num_runs, 7)
    for i in 1:num_runs 
        result = results[i]
        case_name = result["case_name"]
        eos = result["eos"]
        status = result["solver_status"]
        iter = result["num_iterations"]
        time = result["time"]
        feas = result["feasibility"]
        to_write[i, :] = [case_name, i, eos, status, iter, time, feas]
    end 
    open(output_path, "w") do io
        writedlm(io, [permutedims(to_write_header); to_write], ',')
    end
end 


function paper_runs(folder::AbstractString, eos::Symbol; num_runs = 500, 
    output_folder = "./output/", output_file = "8-node-ideal.csv", case_name = "8-node", 
    dimensional = false) 
    data_sample = GasSteadySim._parse_data(folder)
    # julia compiling run 
    solver_return = run_gf_solver(data_sample, eos, method = :newton, show_trace = true)
    Random.seed!(2022)
    results = Dict{Int,Any}()

    for i in 1:num_runs
        results[i] = Dict{String,Any}()
        data = GasSteadySim._parse_data(folder)
        (dimensional == true) && (make_nominal_values_unity!(data))
        perturb_compressor_ratios!(data)
        perturb_injections!(data)
        solver_return = run_gf_solver(data, eos, method = :newton, show_trace = false)
        results[i]["solver_status"] = Int(solver_return.status)
        results[i]["num_iterations"] = solver_return.iterations
        results[i]["time"] = solver_return.time 
        results[i]["feasibility"] = 
            if Int(solver_return.status) in [2, 3]
                "false" 
            elseif Int(solver_return.status) == 1
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

function get_max_deviation(ideal, cnga)
    p_ideal = ideal.sol["nodal_pressure"]
    p_cnga = cnga.sol["nodal_pressure"]
    p_deviation =  maximum([abs(p_ideal[i] - p_cnga[i])/p_cnga[i]*100.0 for i in keys(p_ideal)])
    rho_ideal = ideal.sol["nodal_density"]
    rho_cnga = cnga.sol["nodal_density"]
    rho_deviation =  maximum([abs(rho_ideal[i] - rho_cnga[i])/rho_cnga[i]*100.0 for i in keys(p_ideal)])
    return p_deviation, rho_deviation
end 

function ideal_vs_non_ideal_runs()
    cases = ["GasLib-11", "GasLib-24", "GasLib-40", "GasLib-134"] 
    output_file_p = "./output/ideal_vs_nonideal_max_deviation_pressure.csv"
    output_file_rho = "./output/ideal_vs_nonideal_max_deviation_density.csv"
    data_folder = "./data/"
    num_runs = 500
    data_sample = GasSteadySim._parse_data("./data/2-node/")
    # julia compiling run 
    _ = run_gf_solver(data_sample, :ideal, method = :newton, show_trace = true)

    Random.seed!(2000)
    results_p = Dict{String,Any}(case => [] for case in cases)
    results_rho = Dict{String,Any}(case => [] for case in cases)
    
    for case in cases
        for _ in 1:num_runs 
            data_i = GasSteadySim._parse_data(data_folder * case * "/")
            perturb_compressor_ratios!(data_i)
            perturb_injections!(data_i)
            data_n = deepcopy(data_i)
            ss_i = initialize_simulator(data_i, eos=:ideal)
            ss_n = initialize_simulator(data_n, eos=:full_cnga)
            _ = run_simulator!(ss_i)
            _ = run_simulator!(ss_n)
            deviation_p, deviation_rho = get_max_deviation(ss_i, ss_n)
            push!(results_p[case], deviation_p)
            push!(results_rho[case], deviation_rho)
        end 
    end 

    header = cases 
    data_p = Array{Any,2}(undef, num_runs, 4)
    data_rho = Array{Any,2}(undef, num_runs, 4)
    for i in 1:num_runs 
        data_p[i, :] = [results_p[case][i] for case in cases]
        data_rho[i, :] = [results_rho[case][i] for case in cases]
    end 

    open(output_file_p, "w") do io
        writedlm(io, [permutedims(header); data_p], ',')
    end

    open(output_file_rho, "w") do io
        writedlm(io, [permutedims(header); data_rho], ',')
    end

end 