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

		if !sd.norm {
			ampi = massv2(t.Slice(start, stop), query)
		} else {
			ampi = sd.euclidian(t.Slice(start, stop), query)
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

// func (sd *StreamDAMP) massv2(x, y []float64) float64 {
// 	m, n := len(y), len(x)
// 	meany, meanx := mean(y), movmean(x, m-1, 0)
// 	sigmay, sigmax := std(y), movstd(x, m-1, 0)

// 	slices.Reverse(y)
// 	ry := dsputils.ZeroPadF(y, n)

// 	fz := fft.Convolve(dsputils.ToComplex(x), dsputils.ToComplex(ry))
// 	z := fromComplex(fz)

// 	dist := timesScalar(2, minusScalar(float64(m), rdivide(
// 		minus(z[m-1:n], timesScalar(float64(m)*meany, meanx[m-1:n])),
// 		timesScalar(sigmay, sigmax[m-1:n]),
// 	)))
// 	distSqrt := sqrt(dist)

// 	val := math.Inf(+1)
// 	for _, v := range distSqrt {
// 		if v < val {
// 			val = v
// 		}
// 	}
// 	if math.IsNaN(val) {
// 		// This happens when there's constant regions in the data
// 		return 0
// 	}
// 	return val
// }

func Minkowski(a []float64, b []float64, p float64) float64 {
	if len(a) == 0 || len(b) == 0 {
		panic("Vectors a and b cannot be empty")
	}
	if len(a) != len(b) {
		fmt.Println(len(a), len(b))
		panic("Vectors a and b must be of the same length.")
	}
	var result float64 = 0
	for i := 0; i < len(a); i++ {
		result += math.Pow(math.Abs(a[i]-b[i]), p)
	}
	return math.Pow(result, 1/p)
}

func (sd *StreamDAMP) euclidian(x, y []float64) float64 {
	lx, ly := len(x), len(y)
	val := math.Inf(+1)

	// Whole windows
	// for i := 0; i < lx/ly; i++ {
	// 	// fmt.Println(i, i*ly, (i*ly)+ly)
	// 	v := Minkowski(x[i*ly:(i*ly)+ly], y, 2)
	// 	if v < val {
	// 		val = v
	// 	}
	// }

	// TODO: note
	// sliding windows
	for i := 0; i <= lx-ly; i++ {
		v := Minkowski(x[i:i+ly], y, 2)
		if v < val {
			val = v
		}
	}

	return val
}
