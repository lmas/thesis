package damp

import (
	"math/rand/v2"
	"testing"
)

const benchSize int = 1024 * 10

func initBenchData() []float64 {
	r := rand.New(rand.NewPCG(1, 2))
	benchData := make([]float64, benchSize)
	for i := range benchSize {
		benchData[i] = r.Float64() * 1000
	}
	return benchData
}

func BenchmarkStreamDampNormalised(b *testing.B) {
	data := initBenchData()
	sdamp, err := NewStreamDAMP(1024, 8, 512, true)
	if err != nil {
		b.Fatal(err)
	}
	for b.Loop() {
		sdamp.Push(data[b.N%benchSize])
	}
}

func BenchmarkStreamDampNoneNormalised(b *testing.B) {
	data := initBenchData()
	sdamp, err := NewStreamDAMP(1024, 8, 512, false)
	if err != nil {
		b.Fatal(err)
	}
	for b.Loop() {
		sdamp.Push(data[b.N%benchSize])
	}
}
