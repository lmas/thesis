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
	"math"
	"path/filepath"
	"testing"
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
	ts := NewTimeseries(len(data), false)
	for _, d := range data {
		ts.Push(d)
	}
	if !containsConstantRegions(ts, seq) {
		t.Fatal("Expected data to have constant regions")
	}
	// _, err := DAMP(ts, seq, seq*4)
	// if !strings.Contains(err.Error(), "constant regions") {
	// 	t.Fatalf("expected DAMP to fail on constant regions, got err: %v", err)
	// }
}

const samplesDir string = "samples"

type testSample struct {
	name        string
	maxSize     int
	seqSize     int
	trainSize   int
	topDiscords []int
}

var dataSamples = []testSample{
	{"1-bourkestreetmall", 17490, 24, 24 * 7, []int{
		7837, 7850, 7838, 7852, 7849, 7848, 7847, 7846, 7845, 7842, 7843, 7844,
		7841, 7839, 7840, 7853, 16611, 16610, 7851, 7854, 16609, 16599, 16600,
		16601, 16608, 16607, 16603, 16604, 16605, 16606, 16602, 16598, 16597,
		16596, 7855, 16595, 16612, 7856, 7836, 16594, 7857, 9182, 9181, 7858,
		7835, 9169, 9168, 9170, 9167, 9166, 9171, 9165, 9172, 9164, 9163, 9173,
		9183, 9162, 16613, 9180, 16617, 8475, 8476, 9161,
	}},
	{"2-machining", 44056, 16, 44056 / 9, []int{
		15551, 15550, 15558, 15553, 15552, 15548, 15549, 15554, 15556, 15555,
		15557, 15559, 15560, 15561, 15547, 15544, 15545, 15546, 15543, 15562,
		36781, 15542, 36787, 36790, 36783, 36788, 36780, 36791, 36789, 36782,
		15541, 36793, 36792, 15563, 36795, 36794, 36779, 36778, 36786, 36796,
		36777, 36797, 36776, 36799, 36784, 36798, 36775, 15540, 36785, 15564,
		15567, 36801, 36802, 36800, 36774, 29764, 29762, 29763, 29761, 29765,
		29760, 29759, 29758, 22607,
	}},
}
var topN = 64

func TestStreamDAMPWithDatasets(t *testing.T) {
	for _, s := range dataSamples {
		path := filepath.Join(".", samplesDir, s.name+".in")
		ts, err := ReadTimeseriesFromFile(path, s.maxSize)
		if err != nil {
			t.Fatal(err)
		}
		sd, err := NewStreamDAMP(s.maxSize, s.seqSize, s.trainSize, false)
		if err != nil {
			t.Fatal(err)
		}
		sdamp := NewTimeseries(ts.Len(), false)
		for i := range ts.Len() {
			discord := sd.Push(ts.Get(i))
			sdamp.Push(discord)
		}
		for i, idx := range sdamp.TopIndices(topN) {
			if idx != s.topDiscords[i] {
				t.Fatalf("expected index %v, got %v", s.topDiscords[i], idx)
			}
		}
	}
}
