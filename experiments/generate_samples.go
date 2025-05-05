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

// ABOUT:
// An experiment to compare both implementations of the DAMP algorithm.
// Plain DAMP returns output that matches with the Matlab code provided
// alongside with the original paper.

package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"time"

	"code.larus.se/lmas/thesis/damp"
)

type testSample struct {
	name      string
	maxSize   int
	seqSize   int
	trainSize int
}

var plotSamples = []testSample{
	{"damp/samples/1-bourkestreetmall", 17490, 24, 24 * 7},
	{"damp/samples/2-machining", 44056, 16, 44056 / 9},
	{"damp/samples/knutstorp-tonga", 1024, 16, 512},
}

func main() {
	var times []timing
	for _, s := range plotSamples {
		// Open the dataset
		log.Println("running sample:", s.name)
		tsData, err := damp.ReadTimeseriesFromFile(s.name+".in", 0)
		if err != nil {
			panic(err)
		}

		// Run original DAMP
		start := time.Now()
		tsDamp, err := damp.DAMP(tsData, s.seqSize, s.trainSize)
		stop := time.Now()
		if err != nil {
			panic(err)
		}
		dur1 := stop.Sub(start)
		log.Println("original took:", dur1)
		if err := writeTS(s.name+".1.damp", tsDamp); err != nil {
			panic(err)
		}

		// Run streaming DAMP, normalised
		tsSDamp1 := damp.NewTimeseries(tsData.Len(), false)
		sdamp1, err := damp.NewStreamDAMP(s.maxSize, s.seqSize, s.trainSize, true)
		if err != nil {
			panic(err)
		}
		start = time.Now()
		for i := range tsData.Len() {
			discord := sdamp1.Push(tsData.Get(i))
			tsSDamp1.Push(discord)
		}
		stop = time.Now()
		dur2 := stop.Sub(start)
		log.Print("streaming (normalised=true) took:", dur2)
		if err := writeTS(s.name+".2.damp", tsSDamp1); err != nil {
			panic(err)
		}

		// Run streaming DAMP, non-normalised
		tsSDamp2 := damp.NewTimeseries(tsData.Len(), false)
		sdamp2, err := damp.NewStreamDAMP(s.maxSize, s.seqSize, s.trainSize, false)
		if err != nil {
			panic(err)
		}
		start = time.Now()
		for i := range tsData.Len() {
			discord := sdamp2.Push(tsData.Get(i))
			tsSDamp2.Push(discord)
		}
		stop = time.Now()
		dur3 := stop.Sub(start)
		log.Print("streaming (normalised=false) took:", dur3)
		if err := writeTS(s.name+".3.damp", tsSDamp2); err != nil {
			panic(err)
		}
		times = append(times, timing{
			dataset: s.name,
			dur:     []time.Duration{dur1, dur2, dur3},
		})
	}
	if err := writeTimings("tmp/timings.in", times); err != nil {
		panic(err)
	}
}

func writeTS(path string, ts *damp.Timeseries) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	if err := ts.Write(f); err != nil {
		return err
	}
	return f.Sync()
}

type timing struct {
	dataset string
	dur     []time.Duration
}

func writeTimings(path string, times []timing) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	for _, t := range times {
		_, err := fmt.Fprintf(f, "%s\t %f\t %f\t %f\n",
			filepath.Base(t.dataset), t.dur[0].Seconds(),
			t.dur[1].Seconds(), t.dur[2].Seconds(),
		)
		if err != nil {
			return err
		}
	}
	return f.Sync()
}
