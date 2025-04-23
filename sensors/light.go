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

package sensors

import (
	"fmt"
	"log"
	"math"
	"time"

	"code.larus.se/lmas/thesis/damp"
	tsl2591 "github.com/JenswBE/golang-tsl2591"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api/write"
)

const (
	lightPeriod int = 1000
	lightSeq    int = 60
)

type Light struct {
	debug bool
	tsl   *tsl2591.TSL2591
	sdamp *damp.StreamingDAMP
}

func NewLight(debug bool) (dev *Light, err error) {
	sdamp, err := damp.NewStreamingDAMP(lightSeq*60, lightSeq, lightSeq*4)
	if err != nil {
		return nil, err
	}
	dev = &Light{
		debug: debug,
		sdamp: sdamp,
	}
	dev.tsl, err = tsl2591.NewTSL2591(&tsl2591.Opts{
		Gain:   tsl2591.GainLow,
		Timing: tsl2591.IntegrationTime100MS,
	})
	if err != nil {
		return nil, fmt.Errorf("error opening tsl2591 device: %w", err)
	}
	return
}

func (dev *Light) Close() error {
	return nil
}

func (dev *Light) PeriodTime() time.Duration {
	return time.Duration(lightPeriod) * time.Millisecond
}

func (dev *Light) NewSample(now time.Time) (point *write.Point, err error) {
	val, err := dev.tsl.Lux()
	if err != nil {
		return nil, fmt.Errorf("error reading tsl2591 value: %w", err)
	}
	dist := dev.sdamp.Push(val)
	if math.IsNaN(dist) {
		dist = -1
	}

	if dev.debug {
		log.Printf("light=%f lux\t discord=%f\n", val, dist)
	}
	point = influxdb2.NewPoint(
		"light", // Measurement
		map[string]string{ // Tags
			"unit": "lux",
		},
		map[string]any{ // Fields
			"current": val,
			"discord": dist,
		},
		now, // Timestamp
	)
	return
}
