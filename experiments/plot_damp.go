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
	"log"
	"os"
	"time"

	"code.larus.se/lmas/thesis/damp"
)

// ABOUT:
// An experiment to compare both implementations of the DAMP algorithm.
// Plain DAMP returns output that matches with the Matlab code provided
// alongside with the original paper.

type testSample struct {
	name      string
	maxSize   int
	seqSize   int
	trainSize int
}

var plotSamples = []testSample{
	{"damp/samples/1-bourkestreetmall.in", 17490, 24, 24 * 7},
	{"damp/samples/2-machining.in", 44056, 16, 44056 / 9},
}

func main() {
	for _, s := range plotSamples {
		// Open the dataset
		log.Println("running sample:", s.name)
		tsData, err := damp.ReadTimeseriesFromFile(s.name, s.maxSize)
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
		log.Println("original took:", stop.Sub(start))
		if err := writeTS(s.name+".damp", tsDamp); err != nil {
			panic(err)
		}

		// Run streaming DAMP
		tsSDamp := damp.NewTimeseries(tsData.Len(), false)
		sdamp, err := damp.NewStreamDAMP(s.maxSize, s.seqSize, s.trainSize, false)
		if err != nil {
			panic(err)
		}
		start = time.Now()
		for i := range tsData.Len() {
			discord := sdamp.Push(tsData.Get(i))
			tsSDamp.Push(discord)
		}
		stop = time.Now()
		log.Print("streaming took:", stop.Sub(start))
		if err := writeTS(s.name+".sdamp", tsSDamp); err != nil {
			panic(err)
		}
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
