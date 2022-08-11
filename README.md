# GasFlowRuns
Steady State Gas Flow Solver runs for manuscript "Numerical Solution of the Steady-State Network Flow Equations for a Non-Ideal Gas" in https://arxiv.org/abs/2204.00071

The actual runs are in the src/gf-solver folder written in Julia

GNUPLOT is used to generate the plots that are in the plots/gnuplot folder.
It generates tex files which can be compiled using pdflatex in the plots/tex folder. 

The tables in the paper are generated as CSVs using python. 
The pipenv files and the table generation scripts are in the table-scripts folder.
