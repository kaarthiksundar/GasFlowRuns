include("run-gf-solver.jl")

using Logging

logger = ConsoleLogger(stdout, Logging.Error)

function run_dim_vs_nondim_study()
    eos_list = [:ideal]
    cases = ["GasLib-11", "GasLib-24", "GasLib-40", "GasLib-134"] 

    output_folder = "./output/"
    data_folder = "./data/"

    num_runs = 500 

    for case in cases 
        for eos in eos_list 
            for dimensional in [false, true]
                folder = data_folder * case * "/"
                eos_string = (eos == :ideal) ? "ideal" : "cnga"

                output_file = if dimensional 
                    case * "-" * eos_string * "-d.csv" 
                else 
                    case * "-" * eos_string * ".csv" 
                end 
                paper_runs(folder::AbstractString, eos::Symbol; num_runs = num_runs, 
                    output_folder = output_folder, 
                    output_file = output_file, 
                    case_name = case, dimensional = dimensional) 
            end 
        end 
    end 
end 

function run_kekatos_comparison_study()
    eos_list = [:ideal, :full_cnga]
    cases = ["GasLib-11", "GasLib-24", "GasLib-40", "GasLib-134"] 

    output_folder = "./output/comparison-study/"
    data_folder = "./data/"

    num_runs = 500 

    for case in cases 
        for eos in eos_list 
            for dimensional in [false]
                folder = data_folder * case * "/"
                eos_string = (eos == :ideal) ? "ideal" : "cnga"

                output_file = if dimensional 
                    case * "-" * eos_string * "-d.csv" 
                else 
                    case * "-" * eos_string * ".csv" 
                end 
                paper_runs(folder::AbstractString, eos::Symbol; num_runs = num_runs, 
                    output_folder = output_folder, 
                    output_file = output_file, 
                    case_name = case, dimensional = dimensional) 
            end 
        end 
    end 
end 

run_deviation_study() = ideal_vs_non_ideal_runs()