package sensors

import (
	"fmt"
	"log"
	"time"

	tsl2591 "github.com/JenswBE/golang-tsl2591"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api/write"
)

type Light struct {
	debug bool
	tsl   *tsl2591.TSL2591
}

func NewLight(debug bool) (dev *Light, err error) {
	dev = &Light{
		debug: debug,
	}
	dev.tsl, err = tsl2591.NewTSL2591(&tsl2591.Opts{
		Gain:   tsl2591.GainLow,
		Timing: tsl2591.IntegrationTime500MS,
	})
	if err != nil {
		return nil, fmt.Errorf("error opening tsl2591 device: %w", err)
	}
	return
}

func (dev *Light) Close() error {
	return nil
}

func (dev *Light) NewSample(now time.Time) (point *write.Point, err error) {
	val, err := dev.tsl.Lux()
	if err != nil {
		return nil, fmt.Errorf("error reading tsl2591 value: %w", err)
	}
	if dev.debug {
		log.Printf("light=%f lux\n", val)
	}
	point = influxdb2.NewPoint(
		"light", // Measurement
		map[string]string{ // Tags
			"unit": "lux",
		},
		map[string]any{ // Fields
			"current": val,
		},
		now, // Timestamp
	)
	return
}
