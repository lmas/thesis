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

type StreamDAMP struct {
	data      *Timeseries
	amp       *Timeseries
	maxSize   int
	trainSize int
	seqSize   int
	norm      bool
	bsf       float64
	index     int
}

func NewStreamDAMP(maxSize, seqSize, trainSize int, normalise bool) (sd *StreamDAMP, err error) {
	switch {
	// case seqSize < 10 || seqSize > 1000: // TODO: investigate sequence sizes
	// 	err = fmt.Errorf("subsequence length must be in the range of 10-999")
	case trainSize < seqSize:
		err = fmt.Errorf("training size must be larger than subsequence length")
	case trainSize/seqSize < 2:
		err = fmt.Errorf("training size must be at least twice the size of the subsequence")
	}
	if err != nil {
		return
	}
	sd = &StreamDAMP{
		data:      NewTimeSeries(maxSize, false),
		amp:       NewTimeSeries(maxSize, false),
		maxSize:   maxSize,
		trainSize: trainSize,
		seqSize:   seqSize,
		norm:      normalise,
	}
	return
}

func (sd *StreamDAMP) Push(v float64) float64 {
	tlen := sd.data.Len()
	if tlen == sd.maxSize {
		sd.data.Pop()
		sd.amp.Pop()
		if sd.index > -1 {
			sd.index--
			if sd.index < 0 {
				// Drops the score once in-data value is popped from the buffer
				sd.bsf, sd.index = sd.amp.Max()
			}
		}
	} else {
		tlen++
	}
	sd.data.Push(v)

	if tlen < sd.trainSize {
		// Keep waiting for more training data
		sd.amp.Push(0)
		return 0
	}

	val := sd.processBackward(sd.data, sd.seqSize, tlen-sd.seqSize)
	sd.amp.Push(val)
	return val
}

func (sd *StreamDAMP) processBackward(t *Timeseries, m, i int) float64 {
	size := nextpower2(8 * m)
	ampi := math.Inf(+1) // Positive infinity
	exp := 0
	query := t.Slice(i, i+m)
	for {
		stop := i - (size / 2) + (exp * m) + 1
		if exp == 0 {
			// Case 1: the segment closest to the current subsequence
			stop = i + 1
		}
		start := i - size + (exp * m) + 1
		if start < 1 {
			// Case 2: the segment furthest from the current subsequence
			start = 0
			stop = i + 1
		}

		if sd.norm {
			ampi = massv2(t.Slice(start, stop), query)
		} else {
			ampi = euclidean(t.Slice(start, stop), query)
		}
		if ampi > sd.bsf {
			sd.bsf = ampi
			sd.index = i
		}
		if start < 1 || ampi < sd.bsf {
			break
		}
		// Expands the search for the (possibly) next iteration
		size *= 2
		exp += 1
	}
	return ampi
}

func euclidean(x, y []float64) float64 {
	lx, ly := len(x), len(y)
	dist := math.Inf(+1)
	// Finds the distance of the nearest neighbours, using a sliding window
	for i := 0; i <= lx-ly; i++ {
		window := x[i : i+ly]
		sum := 0.0
		// Calculates the euclidian distance using Minkowski's method:
		// https://en.wikipedia.org/wiki/Minkowski_distance
		for i := 0; i < len(window); i++ {
			sum += math.Pow(math.Abs(window[i]-y[i]), 2)
		}
		// Defer the sqrt(sum) to the end of this function:
		// https://en.m.wikipedia.org/wiki/Euclidean_distance#Squared_Euclidean_distance
		if sum < dist {
			dist = sum
		}
	}
	return math.Sqrt(dist)
}
