include("run-gf-solver.jl")

using Logging

logger = ConsoleLogger(stdout, Logging.Error)

eos_list = [:ideal, :full_cnga]
cases = ["8-node", "GasLib-11", "GasLib-24", 
    "GasLib-40", "GasLib-134"] 

output_folder = "./output/"
data_folder = "./data/"

num_runs = 500 

for case in cases 
    for eos in eos_list 
        folder = data_folder * case * "/"
        eos_string = (eos == :ideal) ? "ideal" : "cnga"
        output_file = case * "-" * eos_string * ".csv" 
        paper_runs(folder::AbstractString, eos::Symbol; num_runs = 500, 
            output_folder = output_folder, 
            output_file = output_file, 
            case_name = case) 
    end 
end 