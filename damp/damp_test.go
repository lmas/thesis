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
	"math"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"

	"gonum.org/v1/plot"
)

func TestNextpower2(t *testing.T) {
	powers := []int{0, 1, 2, 3, 5, 7, 11, 13, 17, 31, 37}
	for _, p := range powers {
		exp := math.Ceil(math.Log2(math.Abs(float64(p))))
		want := int(math.Pow(2, exp))
		got := nextpower2(p)
		if got != want {
			t.Fatalf("expected %d, got %d for test case %d", want, got, p)
		}
	}
}

func TestDAMPWithConstantRegions(t *testing.T) {
	data := []float64{
		96.4512, 96.4512, 96.4512, 96.4512, 96.4512, 96.4512, 96.4512, 96.4512,
		96.4512, 96.4512, 100.53120000000001, 100.53120000000001, 100.53120000000001,
		100.53120000000001, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002, 93.84000000000002,
		93.84000000000002, 93.84000000000002, 93.84000000000002,
	}
	seq := 11
	ts := NewTimeSeries(len(data), false)
	for _, d := range data {
		ts.Push(d)
	}
	if !containsConstantRegions(ts, seq) {
		t.Fatal("Expected data to have constant regions")
	}
	_, _, _, err := DAMP(ts, seq, seq*4)
	if !strings.Contains(err.Error(), "constant regions") {
		t.Fatalf("expected DAMP to fail on constant regions, got err: %v", err)
	}
	sd, err := NewStreamingDAMP(len(data), seq, seq*4)
	if err != nil {
		t.Fatal(err)
	}
	for i, d := range data {
		v := sd.Push(d)
		if i >= sd.trainSize-1 && v != 0 {
			t.Fatalf("expected zero from constant regions, got %v", v)
		}
	}
}

const samplesDir string = "samples"

type testSample struct {
	name      string
	samples   int
	maxSize   int
	seqSize   int
	trainSize int
	precision float64
}

func TestDAMPWithDatasets(t *testing.T) {
	samples := []testSample{
		{"1-bourkestreetmall", 17490, 512, 24, 24 * 7, 0.00000000001},
		{"2-machining", 44056, 8192, 16, 44056 / 9, 0.000001},
	}
	for _, s := range samples {
		// Open the dataset
		t.Log("running sample:", s.name)
		ts, err := readTS(filepath.Join(".", samplesDir, s.name+".in"))
		if err != nil {
			t.Fatal(err)
		}

		// Run original DAMP
		start := time.Now()
		damp, _, _, err := DAMP(ts, s.seqSize, s.trainSize)
		stop := time.Now()
		if err != nil {
			t.Fatalf("expected no errors, got: %s", err)
		}
		err = compareMP(damp, filepath.Join(samplesDir, s.name+".out"), s.precision)
		if err != nil {
			t.Fatal(err)
		}
		t.Log("original took:", stop.Sub(start))

		// Run streaming DAMP
		sdamp := NewTimeSeries(s.samples, false)
		sd, err := NewStreamingDAMP(s.maxSize, s.seqSize, s.trainSize)
		if err != nil {
			t.Fatal(err)
		}
		f, err := os.Open(filepath.Join(".", samplesDir, s.name+".in"))
		if err != nil {
			t.Fatal(err)
		}
		sc := bufio.NewScanner(f)
		var v float64
		start = time.Now()
		for sc.Scan() {
			line := strings.TrimSpace(sc.Text())
			v, err = strconv.ParseFloat(line, 64)
			if err != nil {
				t.Fatal(err)
			}
			val := sd.Push(v)
			sdamp.Push(val)
		}
		stop = time.Now()
		f.Close()
		t.Log("streaming took:", stop.Sub(start))
		if err = sc.Err(); err != nil {
			t.Fatal(err)
		}

		// Plot the data
		start = time.Now()
		pdata, err := PlotFromTimeseries(ts, "Data")
		if err != nil {
			t.Fatal(err)
		}
		pdamp, err := PlotFromTimeseries(damp, "DAMP")
		if err != nil {
			t.Fatal(err)
		}
		psdamp, err := PlotFromTimeseries(sdamp, "Streaming DAMP")
		if err != nil {
			t.Fatal(err)
		}
		w, err := os.Create(s.name + "-plots.png")
		if err != nil {
			t.Error(err)
		}
		if err = SavePlots([]*plot.Plot{pdata, pdamp, psdamp}, w); err != nil {
			t.Error(err)
		}
		w.Close()
		stop = time.Now()
		t.Log("plotting took:", stop.Sub(start))
	}
}
func readTS(path string) (ts *Timeseries, err error) {
	r, err := os.Open(path)
	if err != nil {
		err = fmt.Errorf("error opening input: %s\n", err)
		return
	}
	ts, err = ReadTimeSeries(r)
	if err != nil {
		err = fmt.Errorf("error reading input: %s\n", err)
	}
	defer r.Close()
	return
}

func compareMP(mp *Timeseries, path string, precision float64) (err error) {
	r, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("error opening output: %w\n", err)
	}
	s := bufio.NewScanner(r)
	var f float64
	var i int
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		f, err = strconv.ParseFloat(line, 64)
		if err != nil {
			return
		}
		v := mp.Get(i)
		if !compareFloats(v, f, precision) {
			return fmt.Errorf("expected %.16f, got %.16f (line %d)\n", f, v, i)
		}
		i += 1
	}
	return s.Err()
}

// compareFloats attempts to compare two floats, up to a certain precision.
// Source: https://stackoverflow.com/a/76386543
func compareFloats(a, b, epsilon float64) bool {
	if a == b {
		return true
	}
	diff := math.Abs(a - b)
	if a == 0.0 || b == 0.0 || diff < math.SmallestNonzeroFloat64 {
		return diff < epsilon*math.SmallestNonzeroFloat64
	}
	return diff/(math.Abs(a)+math.Abs(b)) < epsilon
}
