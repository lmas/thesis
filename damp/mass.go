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
	"slices"

	"github.com/mjibson/go-dsp/fft"
)

// massv2 runs "Mueen's Algorithm for Similarity Search, v2" on a subsequence of
// a time series X and returns an array with the distance profiles for a query Y.
// Source: https://www.cs.unm.edu/~mueen/FastestSimilaritySearch.html
func massv2(x, y []float64) (dist []float64) {
	m, n := len(y), len(x)
	meany, meanx := mean(y), movmean(x, m-1, 0)
	sigmay, sigmax := std(y), movstd(x, m-1, 0)

	// WARN: Must make a copy here, as slices.Reverse() will rearrange the underlying array!
	ry := make([]float64, len(y))
	copy(ry, y)
	slices.Reverse(ry)
	for i := m + 1; i <= n; i++ {
		ry = append(ry, 0.0)
	}

	fx := fft.FFT(toComplex(x))
	fy := fft.FFT(toComplex(ry))
	fz := timesComplex(fx, fy)
	z := fromComplex(fft.IFFT(fz))

	dist = timesScalar(2, minusScalar(float64(m), rdivide(
		minus(z[m-1:n], timesScalar(float64(m)*meany, meanx[m-1:n])),
		timesScalar(sigmay, sigmax[m-1:n]),
	)))
	return sqrt(dist)
}

// TODO: one day these funcs will need their own tests

func sqrt(a []float64) (r []float64) {
	r = make([]float64, len(a))
	for i := range a {
		r[i] = math.Sqrt(a[i])
	}
	return
}

func minus(a, b []float64) (r []float64) {
	if len(a) != len(b) {
		panic("mismatched sizes of input slices")
	}
	r = make([]float64, len(a))
	for i := range a {
		r[i] = a[i] - b[i]
	}
	return
}

func rdivide(a, b []float64) (r []float64) {
	if len(a) != len(b) {
		panic("mismatched sizes of input slices")
	}
	r = make([]float64, len(a))
	for i := range a {
		r[i] = a[i] / b[i]
	}
	return
}

func times(a, b []float64) (r []float64) {
	if len(a) != len(b) {
		panic("mismatched sizes of input slices")
	}
	r = make([]float64, len(a))
	for i := range a {
		r[i] = a[i] * b[i]
	}
	return
}

func minusScalar(a float64, b []float64) (r []float64) {
	r = make([]float64, len(b))
	for i := range b {
		r[i] = a - b[i]
	}
	return
}

func timesScalar(a float64, b []float64) (r []float64) {
	r = make([]float64, len(b))
	for i := range b {
		r[i] = a * b[i]
	}
	return
}

func timesComplex(a, b []complex128) (r []complex128) {
	if len(a) != len(b) {
		panic("mismatched sizes of input slices")
	}
	r = make([]complex128, len(a))
	for i := range a {
		r[i] = a[i] * b[i]
	}
	return
}

// Inspired by: https://stackoverflow.com/a/31022598
func toComplex(a []float64) (b []complex128) {
	b = make([]complex128, len(a))
	for i := range a {
		b[i] = complex(a[i], 0)
	}
	return
}

func fromComplex(a []complex128) (b []float64) {
	b = make([]float64, len(a))
	for i := range a {
		b[i] = real(a[i])
	}
	return
}

func sum(a []float64) (sum float64) {
	for _, v := range a {
		sum += v
	}
	return
}

func mean(a []float64) float64 {
	return sum(a) / float64(len(a))
}

// TODO: test
// in: 4, 8, 6, -1, -2, -3, -1, 3, 4, 5
// params: 2, 0
// out: 4 6 6 4.333333333333333 1 -2 -2 -0.3333333333333333 2 4
//
// in: 0, 2, 4, 1, 3, 5, 7
// params: 2, 1
// out: 1 2 1.75 2.5 3.25 4 5

// matlab API: https://se.mathworks.com/help/matlab/ref/movmean.html
func movmean(a []float64, b, f int) (s []float64) {
	for i := range a {
		bi := max(0, i-b)
		fi := min(len(a), i+f+1)
		s = append(s, mean(a[bi:fi]))
	}
	return s
}

// two-pass method matching matlab's API
// Source: https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
// matlab API: https://se.mathworks.com/help/matlab/ref/double.std.html
func std(a []float64) float64 {
	s := sum(a)
	n := float64(len(a))
	var s2 float64
	for _, v := range a {
		s2 += v * v
	}
	return math.Sqrt((s2 - (s*s)/n) / n)

	// TODO
	// Welford's method which is more exact?
	// count, mean, m2 := 0.0, 0.0, 0.0
	// for _, x := range a {
	// 	count += 1
	// 	delta := x - mean
	// 	mean += delta / count
	// 	delta2 := x - mean
	// 	m2 += delta * delta2
	// }
	// return math.Sqrt(m2 / count)
}

// TODO: test
// in: 4, 8, 6, -1, -2, -3, -1, 3, 4, 5
// params: 2, 0, 0
// out: 0 2.8284271247461903 2 4.725815626252608 4.358898943540674 1 1 3.0550504633038935 2.6457513110645907 1
//
// in: 0, 2, 4, 1, 3, 5, 7
// params: 2, 1, 0
// out: 1.4142135623730951 2 1.707825127659933 1.2909944487358056 1.707825127659933 2.581988897471611 2

// matlab API: https://se.mathworks.com/help/matlab/ref/movstd.html
func movstd(a []float64, b, f int) (s []float64) {
	for i := range a {
		bi := max(0, i-b)
		fi := min(len(a), i+f+1)
		s = append(s, std(a[bi:fi]))
	}
	return s
}
