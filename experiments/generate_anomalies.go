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
// Generate examples that highlights the different types of anomalies.

package main

import (
	"fmt"
	"math"
	"os"
)

var dataSize int = 100
var breakPoint int = 65

func main() {
	sinePoint := make([]float64, dataSize)
	for i := range dataSize {
		sinePoint[i] = math.Sin(float64(i) * 0.2)
	}

	sineContext := make([]float64, dataSize)
	copy(sineContext, sinePoint)
	sineContext[breakPoint-2] = 0.7
	if err := writeData("tmp/context.sine", sineContext); err != nil {
		panic(err)
	}

	sineCollective := make([]float64, dataSize)
	copy(sineCollective, sinePoint)
	for i := -5; i <= 5; i++ {
		sineCollective[breakPoint+i] = math.Sin(float64(i)*1.5) * 0.1
	}
	if err := writeData("tmp/collective.sine", sineCollective); err != nil {
		panic(err)
	}

	sinePoint[breakPoint] = 1.25
	if err := writeData("tmp/point.sine", sinePoint); err != nil {
		panic(err)
	}
}

func writeData(path string, data []float64) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	for _, d := range data {
		if _, err := fmt.Fprintf(f, "%f\n", d); err != nil {
			return err
		}
	}
	return nil
}
