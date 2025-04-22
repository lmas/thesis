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
	"fmt"
	"math"
	"slices"

	"github.com/gammazero/deque"
)

type Timeseries struct {
	// data []float64
	data deque.Deque[float64]
}

func NewTimeSeries(size int) *Timeseries {
	var d deque.Deque[float64]
	d.Grow(size)
	for range size {
		d.PushBack(0)
	}
	return &Timeseries{
		// data: make([]float64, size),
		data: d,
	}
}

func (t *Timeseries) Max() float64 {
	m := math.Inf(-1)
	// for _, v := range t.data {
	for i := range t.data.Len() {
		v := t.data.At(i)
		if v > m {
			m = v
		}
	}
	return m
}

func (t *Timeseries) Slice(i, j int) []float64 {
	// return t.data[i:j]
	v := make([]float64, j-i)
	for x := range len(v) {
		v[x] = t.data.At(i + x)
	}
	return v
}

func (t *Timeseries) Get(i int) float64 {
	// return t.data[i]
	return t.data.At(i)
}

func (t *Timeseries) Set(i int, v float64) {
	// t.data[i] = v
	t.data.Set(i, v)
}

func (t *Timeseries) Append(v float64) {
	// t.data = append(t.data, v)
	t.data.PushBack(v)
}

func (t *Timeseries) Push(v float64) {
	len := t.data.Len()
	t.data.PopBack()
	t.data.PushFront(v)
	// TODO: asserting that the buffer doesn't grow until confirmed
	if t.data.Len() != len {
		panic("Buffer grew in size")
	}
}

// Required by plotter interface (can't receive a pointer)
func (t Timeseries) Len() int {
	// return len(t.data)
	return t.data.Len()
}

// Required by plotter interface (can't receive a pointer)
func (t Timeseries) XY(i int) (x, y float64) {
	// return float64(i), t.data[i]
	return float64(i), t.data.At(i)
}

// DAMP calculates the left approximate Matrix Profile found in the time series
// array t, using a subsequence length m and the split point s between training
// and test data.
// The function returns a Matrix Profile vector, index and score of the highest
// scoring discord found in the time series.
func DAMP(t Timeseries, m int, s int) (amp Timeseries, index int, bsf float64, err error) {
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
	}
	if err != nil {
		return
	}
	// TODO: add in the check for finding constant regions (it required a bunch
	// of helper utils, so have to wait until there's enough free time)

	amp = *NewTimeSeries(tlen)
	bsf = math.Inf(-1) // Negative infinity

	// Find the approximately highest discord score from an initial chunk of the data
	for i := s - 1; i < s+16*m; i++ {
		// Stop training if the subsequence attempts to move past the end of the time series
		if i+m-1 > tlen {
			// TODO: remove this block when feeling more secure
			panic("TODO: testing if break is needed. IT WAS!!")
			// break
		}
		query := t.Slice(i, i+m)
		amp.Set(i, slices.Min(massv2(t.Slice(0, i), query)))
	}
	bsf = amp.Max()

	tmpi, val := 0, 0.0
	// Continue examining the rest of the testing data, looking for discords
	for i := s + 16*m; i < tlen-m+1; i++ {
		// Stop searching if trying to move past the end of the time series
		if i+m-1 > tlen {
			// TODO: remove this block when feeling more secure
			panic("TODO: testing if break is needed. IT WAS!!")
			// break
		}
		val, tmpi, bsf = processBackward(t, m, i, bsf)
		amp.Set(i, val)
		if tmpi > -1 {
			index = tmpi
		}
	}
	return
}

func processBackward(t Timeseries, m, i int, bsf float64) (float64, int, float64) {
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
			ampi = slices.Min(massv2(t.Slice(0, i+1), query))
			if ampi > bsf {
				bsf = ampi
			}
			return ampi, i, bsf
		case exp == 0:
			// Case 2: the segment closest to the current subsequence
			stop = i + 1
		}
		ampi = slices.Min(massv2(t.Slice(start, stop), query))
		// Expands the search for the (possibly) next iteration
		size *= 2
		exp += 1
	}
	return ampi, -1, bsf
}
