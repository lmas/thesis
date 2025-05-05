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

# The list of data samples to plot
samples=$(cat << EOF
damp/samples/1-bourkestreetmall
damp/samples/2-machining
EOF
)

################################################################################

plot=$(cat << EOF
set key off;
set style data line;
set linetype 1 lc rgb "#0072bd";
set ytics format "";
set grid;

set term svg size 1280, 720;
set output '%s.svg';
set multiplot layout 3,1;
set title "Data"; plot "%s.in";
set title "DAMP"; plot "%s.in.damp";
set title "StreamDAMP"; plot "%s.in.sdamp";
EOF
)

echo "$samples" | while read sample; do
  echo "Plotting $sample ..."
  cmd=$(printf "$plot\n" "$sample" "$sample" "$sample" "$sample")
  gnuplot -e "$cmd"
done
