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
	"bufio"
	"fmt"
	"io"
	"math"
	"os"
	"slices"
	"strconv"
	"strings"

	"github.com/gammazero/deque"
)

type Timeseries struct {
	data deque.Deque[float64]
}

func NewTimeseries(size int, fill bool) *Timeseries {
	var d deque.Deque[float64]
	d.Grow(size)
	if fill {
		for range size {
			d.PushBack(0)
		}
	}
	return &Timeseries{
		data: d,
	}
}

// ReadTimeseries reads values from a Reader r and creates a new TimeSeries.
func ReadTimeseries(r io.Reader, max int) (t *Timeseries, err error) {
	t = &Timeseries{}
	s := bufio.NewScanner(r)
	var f float64
	var count int
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		if len(line) < 1 {
			continue
		}
		f, err = strconv.ParseFloat(line, 64)
		if err != nil {
			return
		}
		t.Push(f)
		if max > 0 {
			count++
			if count >= max {
				break
			}
		}
	}
	err = s.Err()
	return
}

func ReadTimeseriesFromFile(path string, size int) (ts *Timeseries, err error) {
	r, err := os.Open(path) // #nosec G304
	if err != nil {
		err = fmt.Errorf("error opening input: %s\n", err)
		return
	}
	ts, err = ReadTimeseries(r, size)
	if err != nil {
		err = fmt.Errorf("error reading input: %s\n", err)
	}
	defer r.Close()
	return
}

func (t *Timeseries) Write(w io.Writer) error {
	for i := range t.Len() {
		if _, err := w.Write([]byte(fmt.Sprintf("%f\n", t.Get(i)))); err != nil {
			return err
		}
	}
	return nil
}

func (t *Timeseries) Max() (max float64, index int) {
	max = math.Inf(-1)
	for i := range t.data.Len() {
		v := t.data.At(i)
		if v > max {
			max = v
			index = i
		}
	}
	return
}

func (t *Timeseries) Slice(i, j int) []float64 {
	v := make([]float64, j-i)
	for x := range len(v) {
		v[x] = t.data.At(i + x)
	}
	return v
}

func (t *Timeseries) Get(i int) float64 {
	return t.data.At(i)
}

func (t *Timeseries) Set(i int, v float64) {
	t.data.Set(i, v)
}

func (t *Timeseries) Pop() float64 {
	return t.data.PopFront()
}

func (t *Timeseries) Push(v float64) {
	t.data.PushBack(v)
}

// Required by plotter interface (can't receive a pointer)
func (t Timeseries) Len() int {
	return t.data.Len()
}

// Required by plotter interface (can't receive a pointer)
func (t Timeseries) XY(i int) (x, y float64) {
	return float64(i), t.data.At(i)
}

// Finds the indices for the k top values in the time series.
// Trades CPU time for less memory usage (rather than simply sorting a full copy
// of the data array)
func (t Timeseries) TopIndices(k int) []int {
	if k > t.Len() {
		k = t.Len()
	}
	top := make([]int, k)
	for i := range top {
		top[i] = -1
	}
	for i := range t.Len() {
		x := t.Get(i)
		for j := range top {
			// Case 1: insert into the next free slot
			if top[j] == -1 {
				top[j] = i
				break
			}
			// Case 2: push away lesser items
			y := t.Get(top[j])
			if x > y {
				// Splice together the top of the slice [:j], the new item {i},
				// and bottom of the slice minus the last item [j:len(top)-1]
				top = append(top[:j], append([]int{i}, top[j:len(top)-1]...)...)
				break
			}
		}
	}
	return top
}

func containsConstantRegions(ts *Timeseries, seqSize int) bool {
	var data []float64
	for i := range ts.Len() {
		data = append(data, ts.Get(i))
	}
	var vertcat []float64
	vertcat = append(vertcat, 1)
	vertcat = append(vertcat, diffBetweenItems(data)...)
	vertcat = append(vertcat, 1)
	idx := findNonZero(vertcat)
	len := slices.Max(diffBetweenItems(idx))
	return len >= float64(seqSize)
}

// in: [1, 2, 4, 7, 0]
// out: [ 1,  2,  3, -7]
//
// in: [1 1 2 3 5 8 13 21]
// out:  0     1     1     2     3     5     8
func diffBetweenItems(list []float64) (val []float64) {
	prev := math.NaN()
	for _, v := range list {
		if math.IsNaN(prev) {
			prev = v
			continue
		}
		val = append(val, v-prev)
		prev = v
	}
	return val
}

func findNonZero(list []float64) (val []float64) {
	for i, v := range list {
		if v == 0.0 {
			continue
		}
		val = append(val, float64(i))
	}
	return val
}
