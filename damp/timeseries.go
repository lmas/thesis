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
	"image/color"
	"io"
	"math"
	"strconv"
	"strings"

	"github.com/gammazero/deque"
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/vg"
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

// ReadTimeSeries reads values from a Reader r and creates a new TimeSeries.
func ReadTimeSeries(r io.Reader) (ts Timeseries, err error) {
	s := bufio.NewScanner(r)
	var f float64
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		f, err = strconv.ParseFloat(line, 64)
		if err != nil {
			return
		}
		ts.Append(f)
	}
	err = s.Err()
	return
}

func PlotTimeSeries(ts Timeseries, path string) error {
	pl := plot.New()
	// pl.Title.Text = "Time series"
	// pl.X.Label.Text = "Time"
	// pl.Y.Label.Text = "Value"
	pl.Add(plotter.NewGrid())
	line, err := plotter.NewLine(ts)
	if err != nil {
		return err
	}
	line.Width = vg.Points(1)
	line.Color = color.RGBA{R: 0, G: 114, B: 189, A: 255}
	pl.Add(line)
	return pl.Save(20*vg.Centimeter, 5*vg.Centimeter, path)
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
