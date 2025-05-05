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
	"log"
	"math/rand/v2"
	"os"

	"code.larus.se/lmas/thesis/damp"
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/font"
	"gonum.org/v1/plot/vg"
	"gonum.org/v1/plot/vg/draw"
	"gonum.org/v1/plot/vg/vgimg"
)

// ABOUT:
// This is an experiment for testing how the DAMP algorithm is affected by signal
// noise in the ingested data. Pretty plots are produced as a result (noise.png).

type sample struct {
	dataset string
	size    int
	noise   float64
	buffer  int
	train   int
	window  int
}

var samples = []sample{
	{"damp/samples/1-bourkestreetmall.in", -1, 500, 1024, 24 * 7, 24},
	{"damp/samples/2-machining.in", -1, 0.3, 1024 * 5, 44056 / 9, 16},
	{"tmp/data/humidity.in", 86400 / 2, 0.3, 1024 * 10, 1024 * 5, 16},
	{"tmp/data/pressure.in", 86400 / 2, 15, 1024 * 10, 1024 * 5, 16},
	{"tmp/data/temperature.in", 86400 / 2, 0.3, 1024 * 10, 1024 * 5, 16},
	{"tmp/data/knutstorp-pressure.in", -1, 0.5, 1024, 512, 8},
}

var normalise = true

func main() {
	plots := make([][]*plot.Plot, 4) // Rows
	for i := range len(plots) {
		plots[i] = make([]*plot.Plot, len(samples)) // Columns
	}

	for no, s := range samples {
		log.Println("running sample:", s.dataset)
		ts, err := readTS(s.dataset, s.size)
		if err != nil {
			panic(err)
		}

		r := rand.New(rand.NewPCG(1, 2))
		sd, err := damp.NewStreamDAMP(s.buffer, s.window, s.train, normalise)
		if err != nil {
			panic(err)
		}
		data := damp.NewTimeSeries(ts.Len(), false)
		amp := damp.NewTimeSeries(ts.Len(), false)
		sdNoise, err := damp.NewStreamDAMP(s.buffer, s.window, s.train, normalise)
		if err != nil {
			panic(err)
		}
		dataNoise := damp.NewTimeSeries(ts.Len(), false)
		ampNoise := damp.NewTimeSeries(ts.Len(), false)

		for i := range ts.Len() {
			val := ts.Get(i)
			data.Push(val)
			discord := sd.Push(val)
			amp.Push(discord)

			val += (s.noise * r.Float64()) * float64(r.IntN(3)-1) // Adds some random noise
			dataNoise.Push(val)
			discord = sdNoise.Push(val)
			ampNoise.Push(discord)
		}

		plots[0][no], err = damp.PlotFromTimeseries(data, fmt.Sprintf(
			"%s\n size=%d points, clean", s.dataset, ts.Len(),
		))
		if err != nil {
			panic(err)
		}
		plots[1][no], err = damp.PlotFromTimeseries(amp, fmt.Sprintf(
			"Stream DAMP\n buffer=%d, train=%d, window=%d", s.buffer, s.train, s.window,
		))
		if err != nil {
			panic(err)
		}
		plots[2][no], err = damp.PlotFromTimeseries(dataNoise, fmt.Sprintf(
			"%s\n noise=±%.1f", s.dataset, s.noise,
		))
		if err != nil {
			panic(err)
		}
		plots[3][no], err = damp.PlotFromTimeseries(ampNoise, fmt.Sprintf(
			"Stream DAMP\n buffer=%d, train=%d, window=%d", s.buffer, s.train, s.window,
		))
		if err != nil {
			panic(err)
		}
	}

	log.Println("plotting...")
	writePlots("noise.png", plots)
}

func readTS(path string, size int) (ts *damp.Timeseries, err error) {
	r, err := os.Open(path)
	if err != nil {
		err = fmt.Errorf("error opening input: %s\n", err)
		return
	}
	ts, err = damp.ReadTimeSeries(r, size)
	if err != nil {
		err = fmt.Errorf("error reading input: %s\n", err)
	}
	defer r.Close()
	return
}

func writePlots(path string, plots [][]*plot.Plot) (err error) {
	f, err := os.Create(path)
	if err != nil {
		return
	}
	defer f.Close()
	w := font.Length(len(plots[0]) * 10)
	h := font.Length(len(plots) * 5)
	img := vgimg.New(w*vg.Centimeter, h*vg.Centimeter)
	dc := draw.New(img)
	t := draw.Tiles{
		Rows: len(plots),
		Cols: len(plots[0]),
	}
	c := plot.Align(plots, t, dc)
	for i := range plots {
		for j := range plots[i] {
			plots[i][j].Draw(c[i][j])
		}
	}
	png := vgimg.PngCanvas{Canvas: img}
	_, err = png.WriteTo(f)
	return
}
