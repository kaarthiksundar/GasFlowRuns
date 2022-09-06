include("run-gf-solver.jl")

using Logging

logger = ConsoleLogger(stdout, Logging.Error)

function run_dim_vs_nondim_study(; cases = ["GasLib-11", "GasLib-24", "GasLib-40", "GasLib-134", "GasLib-582"],
    lb_alpha::Float64=1.5, 
    ub_alpha::Float64=1.5, 
    lb_injection::Float64 = 0.75, 
    ub_injection::Float64 = 1.25)
    eos_list = [:ideal, :full_cnga]

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
                paper_runs(folder::AbstractString, eos::Symbol; lb_alpha=lb_alpha, ub_alpha=ub_alpha, 
                    lb_injection=lb_injection, ub_injection=ub_injection,
                     num_runs = num_runs, 
                    output_folder = output_folder, 
                    output_file = output_file, 
                    case_name = case, dimensional = dimensional) 
            end 
        end 
    end 
end 

function run_kekatos_comparison_study(; 
    lb_alpha::Float64 = 1.1, 
    ub_alpha::Float64 = 1.4, 
    lb_injection::Float64 = 0.75, 
    ub_injection::Float64 = 1.25,
    cases = ["GasLib-11", "GasLib-24", "GasLib-40", "GasLib-134", "GasLib-582"])

    eos_list = [:ideal, :full_cnga]
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
                paper_runs(folder::AbstractString, eos::Symbol; lb_alpha=lb_alpha, ub_alpha=ub_alpha, lb_injection= lb_injection, 
                    ub_injection=ub_injection, num_runs = num_runs, 
                    output_folder = output_folder, 
                    output_file = output_file, 
                    case_name = case, dimensional = dimensional) 
            end 
        end 
    end 
end 

function run_multiple_slack_study(;
    lb_alpha::Float64 = 1.5, 
    ub_alpha::Float64 = 1.5, 
    lb_injection::Float64 = 1.0, 
    ub_injection::Float64 = 1.0, 
    cases = ["GasLib-40-multiple-slacks"])

    eos_list = [:ideal, :full_cnga]

    output_folder = "./output/comparison-study/"
    data_folder = "./data/"

    num_runs = 1 

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
                paper_runs(folder::AbstractString, eos::Symbol; lb_alpha=lb_alpha, ub_alpha=ub_alpha, 
                    lb_injection= lb_injection, ub_injection=ub_injection,
                    num_runs = num_runs, 
                    output_folder = output_folder, 
                    output_file = output_file, 
                    case_name = case, dimensional = dimensional) 
            end 
        end 
    end 
end 

run_deviation_study() = ideal_vs_non_ideal_runs()