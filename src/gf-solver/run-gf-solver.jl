using GasSteadySim
using LineSearches
using CPLEX
using JuMP

cplex = optimizer_with_attributes(CPLEX.Optimizer)

function run_gf_solver(file::AbstractString, eos::Symbol)
    ss = initialize_simulator(file, eos=eos, initial_guess_filename="", 
    feasibility_model=:milp)
    is_feasible!(ss, optimizer_with_attributes(CPLEX.Optimizer))
    solver_return = run_simulator!(ss; method = :newton)
    return ss, solver_return
end 

run_ideal_gf_solver(file::AbstractString) = run_gf_solver(file, :ideal)
run_simple_cnga_gf_solver(file::AbstractString) = run_gf_solver(file, :simple_cnga)
run_full_cnga_gf_solver(file::AbstractString) = run_gf_solver(file, :full_cnga)