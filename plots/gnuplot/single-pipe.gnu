set terminal cairolatex standalone pdf dashed transparent size 3, 6\
header \
'\usepackage[scaled]{helvet}\usepackage[T1]{fontenc}\renewcommand\familydefault{\sfdefault}\usepackage{amssymb,bm}\usepackage{siunitx}\usepackage[siunitx]{gnuplottex}\usepackage{xcolor}\definecolor{blue}{RGB}{0,114,178}\definecolor{red}{RGB}{213,94,0}\definecolor{yellow}{RGB}{240,228,66} \definecolor{green}{RGB}{0,158,115}\newcommand{\hl}[1]{\setlength{\fboxsep}{0.75pt}\colorbox{white}{#1}}\usepackage[fontsize=9pt]{fontsize}'

# settings 
set grid ytics lc rgb "#bbbbbb" lw 0.5 lt 1
set grid xtics lc rgb "#bbbbbb" lw 0.5 lt 1


# files to read
if (!exists('ideal_vs_cnga_pressure')) ideal_vs_cnga_pressure = '../../output/ideal-vs-cnga-pressure.csv'
if (!exists('ideal_vs_cnga_density')) ideal_vs_cnga_density = '../../output/ideal-vs-cnga-density.csv'


set style line 1 lc rgb 'grey80' lt 1 lw 3
set style line 2 lc rgb '#E52B50' lt 1 lw 3
set style line 3 lc rgb '#7e2f8e' lt 1 lw 3 

# ==================================================================
# ideal vs non-ideal single-pipe
set output '../tex/ideal-vs-non-ideal.tex'
set datafile separator ','
set key autotitle columnhead

set multiplot layout 3, 1

set lmargin 8
set key opaque 
set key spacing 2.0
set key bottom center

# first plot 
set size 1.0, 0.33
set xrange [0:70]
set xtics 0, 10, 70
set xlabel 'distance (\si{\km})'
set yrange [0:4.5]
set ytics 0.5, 1.0, 4.5
set ylabel 'pressure (\si{\mega\pascal})'
set title '(a)' offset -0.1

plot ideal_vs_cnga_pressure using 1:2 with lines ls 2 dt 4 title 'ideal', \
'' using 1:3 with lines ls 3 title 'non-ideal'

set size 1.0, 0.33 
set yrange [0:35]
set ytics 5, 10, 35
set ylabel 'density (\si{\kilogram\per\cubic\meter})'
set title '(b)' offset -0.1

set key autotitle columnhead
set datafile separator ","

plot ideal_vs_cnga_density using 1:2 with lines ls 2 dt 4 title 'ideal', \
'' using 1:3 with lines ls 3 title 'non-ideal'

set size 1.0, 0.33 
set key top center
set yrange [0:75]
set ytics 0, 25, 75
set ylabel 'rel. change (\%)'
set title '(c)' offset -0.1

set key autotitle columnhead
set datafile separator ","

plot ideal_vs_cnga_pressure using 1:(($3-$2)/$3*100) with lines ls 2 dt 4 title 'pressure', \
ideal_vs_cnga_density using 1:(($3-$2)/$3*100) with lines ls 3 title 'density'

