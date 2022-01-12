using Logging
using GasSteadySim 

logger = SimpleLogger(stdout, Logging.Error)

function get_pressure(x, temperature; eos=:ideal)
    data = GasSteadySim._parse_data("./data/2-node/")
    data["pipes"]["1"]["length"] = x 
    data["simulation_params"]["Temperature (K):"] = temperature
    ss = initialize_simulator(data, eos=eos)
    run_simulator!(ss)
    p_fr = control(ss, :node, 1)[2]
    slack_pressure = GasSteadySim.pascal_to_psi(p_fr * nominal_values(ss, :pressure))
    return slack_pressure, pascal_to_psi(ss.sol["nodal_pressure"][2])
end 

function write_csv(results::Dict{Int,Any}, output_path, lengths; eos=:ideal)
    to_write_header = ["distance", "260", "270", "280", "290", "300"] 
    to_write = Array{Any,2}(undef, length(lengths)+1, 6)
    x = [0.0]
    append!(x, lengths)
    for i in 1:length(x)
        d = x[i]/1000.0
        to_write[i, :] = [d, [results[j][eos][i] for j in 1:5]...]
    end 
    open(output_path, "w") do io
        writedlm(io, [permutedims(to_write_header); to_write], ',')
    end
end 

function run!(eos_list, lengths, temperatures, results)
    for i in 1:length(temperatures)
        temp = temperatures[i] 
        results[i] = Dict{Symbol,Any}(:ideal => [], :full_cnga => []) 
        for x in lengths 
            for eos in eos_list
                println("---------- run --------- ")
                @show x, temp
                p = get_pressure(x, temp, eos=eos)
                if length(results[i][eos]) == 0
                    push!(results[i][eos], p[1])
                end 
                push!(results[i][eos], p[2])
            end 
        end 
    end 
    
end

function run() 
    eos_list = [:ideal, :full_cnga]
    lengths = collect(range(1.0, 40.0, step=1.0)) * 1000.0
    temperatures = collect(range(260.0, 300.0, step=10.0))
    results = Dict{Int,Any}()
    run!(eos_list, lengths, temperatures, results)
    write_csv(results, "./output/1-pipe-ideal.csv", lengths, eos=:ideal)
    write_csv(results, "./output/1-pipe-cnga.csv", lengths, eos=:full_cnga)
end 

run()