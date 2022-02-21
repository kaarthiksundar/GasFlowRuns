set terminal cairolatex standalone pdf dashed transparent size 3, 3 \
header \
'\usepackage[scaled]{helvet}\usepackage[T1]{fontenc}\renewcommand\familydefault{\sfdefault}\usepackage{amssymb,bm}\usepackage{xcolor}\definecolor{blue}{RGB}{0,114,178}\definecolor{red}{RGB}{213,94,0}\definecolor{yellow}{RGB}{240,228,66} \definecolor{green}{RGB}{0,158,115}\newcommand{\hl}[1]{\setlength{\fboxsep}{0.75pt}\colorbox{white}{#1}}\usepackage[fontsize=9pt]{fontsize}'


output = '../tex/domain.tex'
set output output

# settings 
set grid ytics lc rgb "#bbbbbb" lw 0.5 lt 1
set grid xtics lc rgb "#bbbbbb" lw 0.5 lt 1
# set mxtics 
# set mytics

set style line 1 lc rgb 'grey80' lt 1 lw 2
set style line 2 lc rgb '#D55E00' lt 1 lw 2
set style line 3 lc rgb '#0072B2' lt 1 lw 2
set style arrow 1 head filled size screen 0.03,15,45 lc 'black' lw 2 lt 1

set yrange [-1:1]
set xrange[-1.5:1.0]
set format x ""
set format y ""
set xzeroaxis lc 'black' lt 1 lw 2
set yzeroaxis lc 'black' lt 1 lw 2
set arrow to 1,0 as 1
set arrow to 0,1 as 1
set label '$0$'  at 0.05,-0.08
set label '$p$'  at 0.9,-0.08
set label '$\Pi(p)$' at 0.05,0.9
set label '\textcolor{blue}{$-1.5\cdot b_1/b_2$}' at -1,-0.08
set label '\textcolor{red}{Ideal}' at -0.4, 0.25 front
set label '\textcolor{blue}{CNGA}' at -1.2, -0.5 front
unset xlabel
unset ylabel

f(x) = x**2 
g(x) = x**2 + x**3

plot [-1.5:1.0] NaN notitle, \
[0.0:1.0] f(x) notitle ls 2 lw 4,\
[0.0:1.0] g(x) notitle ls 3 lw 4, \
[-1.5:0] f(x) notitle ls 2 lw 4 dt '-', \
[-1:0] g(x) notitle ls 3 lw 4 dt '-', \
[-1.5:-1] g(x) notitle ls 3 lw 4, \
"<echo '-1 0'"  with points lc rgb '#0072B2' pointtype 7 pointsize 0.5 notitle 


