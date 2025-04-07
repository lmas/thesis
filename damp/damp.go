// Copyright (C) 2025 A.Svensson

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.

// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

package main

import (
	"math"
	"slices"
)

type TimeSeries []float64
type MatrixProfile []float64

// DAMP calculates the left approximate Matrix Profile found in the time series
// array t, using a subsequence length m and the split point s between training
// and test data.
// The function returns a Matrix Profile vector, index and score of the highest
// scoring discord found in the time series.
func DAMP(t TimeSeries, m int, s int) (amp MatrixProfile, index int, bsf float64) {

	// TODO: add the initial condition checks

	tlen, tmpi := len(t), 0
	amp = make(MatrixProfile, tlen)
	bsf = math.Inf(-1) // Negative infinity

	// Find the "relatively high" discord score in the training data, that will be the best so far
	for i := s - 1; i < s+16*m; i++ {
		// Stop training if the subsequence attempts to move past the end of the time series
		if i+m-1 > tlen {
			// TODO: remove this block when feeling more secure
			panic("TODO: testing if break is needed. IT WAS!!")
			// break
		}
		query := t[i : i+m]
		amp[i] = slices.Min(massv2(t[:i], query))
	}
	bsf = slices.Max(amp)

	// Continue examining the testing data, looking for discords
	for i := s + 16*m; i < tlen-m+1; i++ {
		// Stop searching if trying to move past the end of the time series
		if i+m-1 > tlen {
			// TODO: remove this block when feeling more secure
			panic("TODO: testing if break is needed. IT WAS!!")
			// break
		}
		amp[i], tmpi, bsf = searchExpandingSubsequence(t, m, i, bsf)
		if tmpi > -1 {
			index = tmpi
		}
	}
	return
}

func searchExpandingSubsequence(t []float64, m, i int, bsf float64) (float64, int, float64) {
	size := nextPowerOfTwo(8 * m)
	ampi := math.Inf(0) // Positive infinity
	exp := 0
	query := t[i : i+m]
	for ampi >= bsf {
		start := i - size + 1 + (exp * m)
		stop := i - (size / 2) + (exp * m) + 1
		switch {
		case start < 1:
			// Case 1: the segment furthest from the current subsequence
			// a.k.a. the start of the time series
			ampi = slices.Min(massv2(t[:i+1], query))
			if ampi > bsf {
				bsf = ampi
			}
			return ampi, i, bsf
		case exp == 0:
			// Case 2: the segment closest to the current subsequence
			ampi = slices.Min(massv2(t[i-size+1:i+1], query))
		default:
			// Case 3: all other segments in between
			ampi = slices.Min(massv2(t[start:stop], query))
		}
		// Expands the search for the (possibly) next iteration
		size *= 2
		exp += 1
	}
	return ampi, -1, bsf
}
