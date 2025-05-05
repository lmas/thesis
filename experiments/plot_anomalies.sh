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
# Generates example plots for the different types of anomalies in time series data.

plot=$(cat << EOF
set key off;
set style data line;
set linetype 1 linecolor rgb "#0072bd" linewidth 3;
set xtics 0,20,100;
set ytics -1.5,1.5 format "";
set grid;

set term png size 1280, 360 font "Default,14";
set output "images/anomalies-example.png";
set multiplot layout 1,3;

set object 1 circle at 65,1.25 size 2 fillcolor rgb "#ff7f7f" fillstyle solid;
set title "Point Anomaly"; plot "tmp/point.sine";
unset object 1;

set object 2 circle at 63,0.7 size 2 fillcolor rgb "#ff7f7f" fillstyle solid;
set title "Context Anomaly"; plot "tmp/context.sine";
unset object 2;

set object 3 circle at 65,0 size 7 fillcolor rgb "#ff7f7f" fillstyle solid;
set title "Collective Anomaly"; plot "tmp/collective.sine";
unset object 3;
EOF
)

gnuplot -e "$plot"
