package sensors

import (
	"fmt"

	tsl2591 "github.com/JenswBE/golang-tsl2591"
)

type Light struct {
	tsl *tsl2591.TSL2591
}

func NewLight() (dev *Light, err error) {
	dev = &Light{}
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

func (dev *Light) Value() (val float64, err error) {
	val, err = dev.tsl.Lux()
	if err != nil {
		return -1, fmt.Errorf("error reading tsl2591 value: %w", err)
	}
	return
}
