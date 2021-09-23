using GasSteadySim

function run_gf_solver(file::AbstractString, eos::Symbol)
    ss = initialize_simulator(file, eos=eos, initial_guess_filename="")
    solver_return = run_simulator!(ss)
    println(solver_return.status)
end 

run_ideal_gf_solver(file::AbstractString) = run_gf_solver(file, :ideal)
run_simple_cnga_gf_solver(file::AbstractString) = run_gf_solver(file, :simple_cnga)
run_full_cnga_gf_solver(file::AbstractString) = run_gf_solver(file, :full_cnga)