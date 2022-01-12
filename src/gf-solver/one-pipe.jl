using Logging
using GasSteadySim 

logger = SimpleLogger(stdout, Logging.Error)

get_data(folder::AbstractString) = GasSteadySim._parse_data(folder)

eos_list = [:ideal, :full_cnga]
lengths = collect(range(0.5, 10.0, step=0.5)) * 1000.0
lengths = [500.0]
temperatures = collect(range(260.0, 300.0, step=10.0))
temperatures = [260.0]
results = Dict{Int,Any}()

function modify_data!(data, len, temperature)
    data["simulation_params"]["Temperature (K):"] = temperature 
    data["pipes"]["1"]["length"] = len
end 

function run()
    for i in 1:length(temperatures)
        temp = temperatures[i] 
        results[i] = Dict{Symbol,Any}(:ideal => [], :full_cnga => []) 
        for x in lengths 
            data = get_data("./data/2-node/")
            modify_data!(data, x, temp)
            for eos in eos_list
                println("---------- run --------- ")
                ss = initialize_simulator(data, eos=eos)
                solver_return = run_simulator!(ss)
                println("$x, $eos -> $(ss.sol["nodal_pressure"])\n\n")
            end 
        end 
    end 
end

run()