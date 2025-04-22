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
	"bufio"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
)

const samplesDir string = "samples"

type testSample struct {
	name      string
	m         int
	spi       int
	precision float64
}

func TestDAMPWithDatasets(t *testing.T) {
	samples := []testSample{
		{"1-bourkestreetmall", 24, 24 * 7, 0.00000000001},
		{"2-machining", 16, 44056 / 9, 0.000001},
	}
	for _, s := range samples {
		t.Log("running sample:", s.name)
		ts, err := readTS(filepath.Join(".", samplesDir, s.name+".in"))
		if err != nil {
			t.Fatal(err)
		}
		start := time.Now()
		mp, _, _, err := DAMP(ts, s.m, s.spi)
		stop := time.Now()
		if err != nil {
			t.Fatalf("expected no errors, got: %s", err)
		}
		err = compareMP(mp, filepath.Join(samplesDir, s.name+".out"), s.precision)
		if err != nil {
			t.Fatal(err)
		}
		t.Log("took:", stop.Sub(start))
		if err = PlotTimeSeries(ts, s.name+"-in.png"); err != nil {
			t.Fatal(err)
		}
		if err = PlotTimeSeries(mp, s.name+"-mp.png"); err != nil {
			t.Fatal(err)
		}
	}
}
func readTS(path string) (ts Timeseries, err error) {
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

func compareMP(mp Timeseries, path string, precision float64) (err error) {
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
