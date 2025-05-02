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

package damp

import (
	"fmt"
	"math"
)

// DAMP calculates the left approximate Matrix Profile found in the time series
// array t, using a subsequence length m and the split point s between training
// and test data.
// The function returns a Matrix Profile vector, index and score of the highest
// scoring discord found in the time series.
func DAMP(t *Timeseries, m int, s int) (amp *Timeseries, err error) {
	// Validate the incoming data and ensure it's in good working condition
	tlen := t.Len()
	switch {
	case m <= 10 || m > 1000:
		err = fmt.Errorf("subsequence length 'm' must be in the range of 11-999")
	case s < m:
		err = fmt.Errorf("s must be larger than or equal to m")
	case s > (tlen - m + 1):
		err = fmt.Errorf("s must be less than length(t) - m + 1")
	case s/m < 4:
		err = fmt.Errorf("s/m must be above 3 (cycles), to prevent false positives")
	case containsConstantRegions(t, m) == true:
		err = fmt.Errorf("t contains near constant regions, which can cause false positives/negatives and other bad values")
	}
	if err != nil {
		return
	}
	// TODO: add in the check for finding constant regions (it required a bunch
	// of helper utils, so have to wait until there's enough free time)

	// Find the approximately highest discord score from an initial chunk of the data
	amp = NewTimeSeries(tlen, true)
	for i := s - 1; i < s+16*m; i++ {
		// Stop training if the subsequence attempts to move past the end of the time series
		if i+m-1 > tlen {
			// TODO: remove this block when feeling more secure
			panic("TODO: testing if break is needed. IT WAS!!")
			// break
		}
		query := t.Slice(i, i+m)
		amp.Set(i, massv2(t.Slice(0, i), query))
	}
	bsf, _ := amp.Max()

	val := 0.0
	// Continue examining the rest of the testing data, looking for discords
	for i := s + 16*m; i < tlen-m+1; i++ {
		// Stop searching if trying to move past the end of the time series
		if i+m-1 > tlen {
			// TODO: remove this block when feeling more secure
			panic("TODO: testing if break is needed. IT WAS!!")
			// break
		}
		val, bsf = processBackward(t, m, i, bsf)
		amp.Set(i, val)
	}
	return
}

func processBackward(t *Timeseries, m, i int, bsf float64) (float64, float64) {
	size := nextpower2(8 * m)
	ampi := math.Inf(0) // Positive infinity
	exp := 0
	query := t.Slice(i, i+m)
	for ampi >= bsf {
		start := i - size + (exp * m) + 1
		stop := i - (size / 2) + (exp * m) + 1
		switch {
		case start < 1:
			// Case 1: the segment furthest from the current subsequence
			// a.k.a. the start of the time series
			ampi = massv2(t.Slice(0, i+1), query)
			if ampi > bsf {
				bsf = ampi
			}
			return ampi, bsf
		case exp == 0:
			// Case 2: the segment closest to the current subsequence
			stop = i + 1
		}
		ampi = massv2(t.Slice(start, stop), query)
		// Expands the search for the (possibly) next iteration
		size *= 2
		exp += 1
	}
	return ampi, bsf
}

// Calculates the next power of two
// Source: https://stackoverflow.com/a/4398845
func nextpower2(v int) int {
	v--
	v |= v >> 1
	v |= v >> 2
	v |= v >> 4
	v |= v >> 8
	v |= v >> 16
	v++
	return v
}

// Checks if a number is a power of two
// Source: https://stackoverflow.com/a/108360
// func isPowerOfTwo(v int) bool {
// 	if v == 0 {
// 		return true
// 	}
// 	return v&(v-1) == 0
// }
