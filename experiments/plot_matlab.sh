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
# Generates example plot using the matlab dataset.
# Note that xtics steps forward using step size = max amount of samples (44056) / 6 ticks

plot=$(cat << EOF
set key off;
set style data line;
set linetype 1 lc rgb "#0072bd";
set xtics("0.5" 7342,"1.0" 14684, "1.5" 22026, "2.0" 29368, "2.5" 36710, "3.0" 44052);
set ytics format "";
set grid;

set term png size 1280, 720 font "Default,14";
set output 'images/matlab-example.png';
set multiplot layout 2,1;
set title "Data"; plot "damp/samples/2-machining.in";
set title "DAMP"; plot "damp/samples/2-machining.out";
EOF
)

gnuplot -e "$plot"
