#!/bin/sh

# Copyright (C) 2025 A.Svensson
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# ABOUT:
# Simple helper script to plot data files using GNUplot

set -eu

while read sample; do
  path=$(echo "$sample" | cut -d ';' -f 1)
  unit=$(echo "$sample" | cut -d ';' -f 2)
  gnuplot <<- EOF
  set key off
  set style data line
  set linetype 1 lc rgb "#0072bd"
  set grid
  set term png size 720, 1280 font "Default,14"
  set output "images/analysis-$path.png"
  set multiplot layout 5,1
  set xlabel "Time (n)"
  set ylabel "$unit"
  set title "Data"; plot "damp/samples/$path.in"
  set ylabel "Discord score (arb. unit)"
  set title "Reference DAMP"; plot "damp/samples/$path.out"
  set title "DAMP"; plot "tmp/$path.1.damp"
  set title "Stream DAMP (normalised=true)"; plot "tmp/$path.2.damp"
  set title "Stream DAMP (normalised=false)"; plot "tmp/$path.3.damp"
EOF
done << EOF
1-bourkestreetmall;Pedestrians (people/h)
2-machining;Arbitrary unit
knutstorp-tonga;Pressure (hPa)
EOF

gnuplot <<- EOF
set style data histogram
set style fill solid
set key left reverse Left
set ylabel "Time (ms/data point)"
set term png size 1280,720 font "Default,14"
set output 'images/analysis-timings.png'
plot "tmp/timings.in" using 2:xtic(1) title "DAMP", \
"tmp/timings.in" using 3 title "Stream DAMP (normalised=true)", \
"tmp/timings.in" using 4 title "Stream DAMP (normalised=false)"
EOF
