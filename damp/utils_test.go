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

func TestNextPowerOfTwo(t *testing.T) {
	powers := []int{0, 1, 2, 3, 5, 7, 11, 13, 17, 31, 37}
	for _, p := range powers {
		exp := math.Ceil(math.Log2(math.Abs(float64(p))))
		want := int(math.Pow(2, exp))
		got := nextPowerOfTwo(p)
		if got != want {
			t.Fatalf("expected %d, got %d for test case %d", want, got, p)
		}
	}
}
