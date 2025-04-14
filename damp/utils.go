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
	"io"
	"strconv"
	"strings"
)

// ReadTimeSeries reads values from a Reader r and creates a new TimeSeries.
func ReadTimeSeries(r io.Reader) (ts TimeSeries, err error) {
	s := bufio.NewScanner(r)
	var f float64
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		f, err = strconv.ParseFloat(line, 64)
		if err != nil {
			return
		}
		ts = append(ts, f)
	}
	err = s.Err()
	return
}

// Calculates the next power of two
// Source: https://stackoverflow.com/a/4398845
func nextpower2(v int) int {
	v--
	v |= v >> 1
	v |= v >> 2
	v |= v >> 4
	v |= v >> 8
	v |= v >> 16
	v++
	return v
}

// Checks if a number is a power of two
// Source: https://stackoverflow.com/a/108360
// func isPowerOfTwo(v int) bool {
// 	if v == 0 {
// 		return true
// 	}
// 	return v&(v-1) == 0
// }
