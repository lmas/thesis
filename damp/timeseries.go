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
	"slices"
	"strconv"
	"strings"

	"github.com/gammazero/deque"
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/font"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/vg"
	"gonum.org/v1/plot/vg/draw"
	"gonum.org/v1/plot/vg/vgimg"
)

type Timeseries struct {
	// data []float64
	data deque.Deque[float64]
}

func NewTimeSeries(size int, fill bool) *Timeseries {
	var d deque.Deque[float64]
	d.Grow(size)
	if fill {
		for range size {
			d.PushBack(0)
		}
	}
	return &Timeseries{
		// data: make([]float64, size),
		data: d,
	}
}

// ReadTimeSeries reads values from a Reader r and creates a new TimeSeries.
func ReadTimeSeries(r io.Reader) (t *Timeseries, err error) {
	t = &Timeseries{}
	s := bufio.NewScanner(r)
	var f float64
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		f, err = strconv.ParseFloat(line, 64)
		if err != nil {
			return
		}
		t.Push(f)
	}
	err = s.Err()
	return
}

func PlotFromTimeseries(t *Timeseries, title string) (p *plot.Plot, err error) {
	p = plot.New()
	p.Title.Text = title
	p.HideY()
	p.Add(plotter.NewGrid())
	line, err := plotter.NewLine(t)
	if err != nil {
		return nil, err
	}
	line.Width = vg.Points(1)
	line.Color = color.RGBA{R: 0, G: 114, B: 189, A: 255}
	p.Add(line)
	return
}

func SavePlots(plots []*plot.Plot, w io.Writer) (err error) {
	h := font.Length(len(plots) * 5)
	img := vgimg.New(20*vg.Centimeter, h*vg.Centimeter)
	dc := draw.New(img)
	t := draw.Tiles{
		Rows: len(plots),
		Cols: 1,
	}
	pc := make([][]*plot.Plot, len(plots))
	for i, p := range plots {
		pc[i] = make([]*plot.Plot, 1)
		pc[i][0] = p
	}
	c := plot.Align(pc, t, dc)
	for i := range plots {
		pc[i][0].Draw(c[i][0])
	}
	png := vgimg.PngCanvas{Canvas: img}
	_, err = png.WriteTo(w)
	return
}

func (t *Timeseries) Max() (max float64, index int) {
	max = math.Inf(-1)
	// for _, v := range t.data {
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

func (t *Timeseries) Pop() float64 {
	return t.data.PopFront()
}

func (t *Timeseries) Push(v float64) {
	t.data.PushBack(v)
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

func containsConstantRegions(ts *Timeseries, seqSize int) bool {
	var data []float64
	for i := range ts.Len() {
		data = append(data, ts.Get(i))
	}
	var vertcat []float64
	vertcat = append(vertcat, 1)
	vertcat = append(vertcat, diff(data)...)
	vertcat = append(vertcat, 1)
	idx := find(vertcat)
	len := slices.Max(diff(idx))
	return len >= float64(seqSize)
}

// in: [1, 2, 4, 7, 0]
// out: [ 1,  2,  3, -7]
//
// in: [1 1 2 3 5 8 13 21]
// out:  0     1     1     2     3     5     8
func diff(list []float64) (val []float64) {
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

func find(list []float64) (val []float64) {
	for i, v := range list {
		if v == 0.0 {
			continue
		}
		val = append(val, float64(i))
	}
	return val
}
