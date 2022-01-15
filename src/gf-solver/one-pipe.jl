using Logging
using GasSteadySim 
using DelimitedFiles

logger = SimpleLogger(stdout, Logging.Error)

function get_pressure(x; eos=:ideal)
    data = GasSteadySim._parse_data("./data/2-node/")
    data["pipes"]["1"]["length"] = x 
    ss = initialize_simulator(data, eos=eos)
    run_simulator!(ss)
    p_fr = control(ss, :node, 1)[2]
    slack_pressure = p_fr * nominal_values(ss, :pressure) * 1e-6
    return slack_pressure, ss.sol["nodal_pressure"][2] * 1e-6
end 

function get_density(x; eos=:ideal)
    data = GasSteadySim._parse_data("./data/2-node/")
    data["pipes"]["1"]["length"] = x 
    ss = initialize_simulator(data, eos=eos)
    run_simulator!(ss)
    p_fr = control(ss, :node, 1)[2] 
    rho_fr = (eos == :ideal) ? GasSteadySim._pressure_to_density_ideal(p_fr, ss.nominal_values, ss.params) :
        GasSteadySim._pressure_to_density_full_cnga(p_fr, ss.nominal_values, ss.params)
    rho_fr *= nominal_values(ss, :density)
    p = ss.sol["nodal_pressure"][2] / nominal_values(ss, :pressure)
    rho = (eos == :ideal) ? GasSteadySim._pressure_to_density_ideal(p, ss.nominal_values, ss.params) :
        GasSteadySim._pressure_to_density_full_cnga(p, ss.nominal_values, ss.params)
    rho *= nominal_values(ss, :density)
    return rho_fr, rho
end 

function write_csv(results::Dict{Symbol,Any}, output_path, lengths)
    to_write_header = ["distance", "ideal", "cnga"] 
    to_write = Array{Any,2}(undef, length(lengths)+1, 3)
    x = [0.0]
    append!(x, lengths)
    for i in 1:length(x)
        d = x[i]/1000.0
        to_write[i, :] = [d, results[:ideal][i], results[:full_cnga][i]]
    end 
    open(output_path, "w") do io
        writedlm(io, [permutedims(to_write_header); to_write], ',')
    end
end 

function run!(eos_list, lengths, results; type=:pressure)
    for x in lengths 
        for eos in eos_list
            p = (type == :pressure) ? get_pressure(x, eos=eos) : get_density(x, eos=eos)
            if length(results[eos]) == 0
                push!(results[eos], p[1])
            end 
            push!(results[eos], p[2])
        end 
    end 
end 


function run() 
    eos_list = [:ideal, :full_cnga]
    lengths = collect(range(1.0, 70.0, step=1.0)) * 1000.0
    results = Dict{Symbol,Any}(:ideal => [], :full_cnga => []) 
    run!(eos_list, lengths,  results, type=:pressure)
    write_csv(results, "./output/ideal-vs-cnga-pressure.csv", lengths)
    results = Dict{Symbol,Any}(:ideal => [], :full_cnga => []) 
    run!(eos_list, lengths,  results, type=:density)
    write_csv(results, "./output/ideal-vs-cnga-density.csv", lengths)
end 

run()