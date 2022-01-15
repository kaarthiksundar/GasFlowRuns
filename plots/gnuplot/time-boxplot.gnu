set terminal cairolatex standalone pdf dashed transparent size 3, 3 \
header \
'\usepackage{mathpazo,amssymb,bm}\usepackage{xcolor}\definecolor{blue}{RGB}{0,114,178}\definecolor{red}{RGB}{213,94,0}\definecolor{yellow}{RGB}{240,228,66} \definecolor{green}{RGB}{0,158,115}\newcommand{\hl}[1]{\setlength{\fboxsep}{0.75pt}\colorbox{white}{#1}}\usepackage[fontsize=9pt]{fontsize}'

output = '../tex/time-box.tex'

# settings 
set grid ytics lc rgb "#bbbbbb" lw 0.5 lt 1
set grid xtics lc rgb "#bbbbbb" lw 0.5 lt 1
set mxtics 
set mytics

set datafile separator ','
set key autotitle columnhead
set style fill solid 0.7 border -1
set style boxplot outliers pointtype 7
set style data boxplot
set boxwidth 0.3
set pointsize 0.25
set style line 1 lc rgb 'grey80' lt 1 lw 2
set style line 2 lc rgb '#e52b50' lt 1 lw 2
set style line 3 lc rgb '#7e2f8e' lt 1 lw 2

set key bottom right
set logscale y
set format y '$10^{%L}$'
set key spacing 1.5
set ylabel 'time (sec.)'
set xrange [1.0:12.0]
set xtics   ('11' 2.0, '24' 5.0, '40' 8.0, '134' 11.0)
set xlabel 'GasLib instance'
set output output
plot '../../output/GasLib-11-ideal.csv' using (1.5):7 ls 2 title 'ideal', \
'../../output/GasLib-11-cnga.csv' using (2.5):7 ls 3 title 'non-ideal', \
'../../output/GasLib-24-ideal.csv' using (4.5):7 ls 2 notitle, \
'../../output/GasLib-24-cnga.csv' using (5.5):7 ls 3 notitle, \
'../../output/GasLib-40-ideal.csv' using (7.5):7 ls 2 notitle, \
'../../output/GasLib-40-cnga.csv' using (8.5):7 ls 3 notitle, \
'../../output/GasLib-134-ideal.csv' using (10.5):7 ls 2 notitle, \
'../../output/GasLib-134-cnga.csv' using (11.5):7 ls 3 notitle