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
# Generates simplified plots to be used as initial examples in the report.

gnuplot <<- EOF
set style data line
set linetype 1 lc rgb "#0072bd"
set xlabel "Time (T)"
set grid
set key off
set term png size 1280, 720 font "Default,14"
set output 'images/example-point.png'
set multiplot layout 2,1

set ylabel "Pressure (hPa)"
plot "damp/samples/knutstorp-tonga.in"
set arrow from 32000,2.4 to 36000,2.75 linewidth 2
set ylabel "Discord score (arb. unit)"
plot "damp/samples/knutstorp-tonga.3.damp"
EOF

gnuplot <<- EOF
set style data line
set linetype 1 lc rgb "#0072bd"
set xlabel "Time (minutes)"
set xtics("0.5" 7342,"1.0" 14684, "1.5" 22026, "2.0" 29368, "2.5" 36710, "3.0" 44052)
set grid
set key off
set term png size 1280, 720 font "Default,14"
set output 'images/example-pattern.png'
set multiplot layout 2,1

set ylabel "Arbitrary unit"
set title "Data"; plot "damp/samples/2-machining.in"
set arrow from 32000,2.4 to 36000,2.75 linewidth 2
set ylabel "Discord score (arb. unit)"
set title "DAMP"; plot "damp/samples/2-machining.out"
EOF
