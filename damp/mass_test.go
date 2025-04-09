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
	"math"
	"testing"
)

func TestMASSV2ContainsNaNs(t *testing.T) {
	data := []float64{91, 260, 621, 647, 984, 1353, 2535, 3027, 2201, 2073}
	query := []float64{16, 101, 346}
	got := massv2(data, query)
	for _, v := range got {
		if math.IsNaN(v) {
			t.Fatalf("slice contains NaNs")
		}
	}
}

func TestMASSV2IsOK(t *testing.T) {
	data := []float64{91, 260, 621, 647, 984, 1353, 2535, 3027, 2201, 2073}
	query := []float64{16, 101, 346}
	want := []float64{
		0.11561068885697222, 1.2468697081392321, 0.3224088232756958, 0.42634912677251185,
		0.03625190113738389, 0.8680563733942075, 3.1310107439040085, 3.270034910001683,
	}
	got := massv2(data, query)
	if len(got) != len(want) {
		t.Fatalf("mismatched sizes")
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("got %f, expected %f", got[i], want[i])
		}
	}
}
