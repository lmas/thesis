package sensors

import (
	"fmt"
	"log"
	"strings"
	"time"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api/write"
	"github.com/kidoman/embd"
	"github.com/stratux/goflying/icm20948"
)

type Gyro struct {
	debug bool
	bus   embd.I2CBus
	icm   *icm20948.ICM20948
}

func NewGyro(debug bool) (dev *Gyro, err error) {
	dev = &Gyro{
		debug: debug,
	}
	dev.bus = embd.NewI2CBus(1)
	dev.icm, err = icm20948.NewICM20948(
		&dev.bus,
		2000,  // Gyro sensitivity (250, 500, 1000, or 2000. in deg/s)
		2,     // Accel. sensitivity (2, 4, 8, or 16. in "G" as in gravity?)
		50,    // Sample rate (in Hz)
		false, // Disable magnetometer
		true,  // Apply HW offsets?
	)
	if err != nil {
		dev.bus.Close()
		return nil, fmt.Errorf("error opening icm20948 device: %w", err)
	}
	return
}

func (dev *Gyro) Close() error {
	dev.icm.CloseMPU()
	err := dev.bus.Close()
	if err != nil {
		return fmt.Errorf("error closing bus: %w", err)
	}
	return nil
}

func (dev *Gyro) NewSample(now time.Time) (point *write.Point, err error) {
	mpu := <-dev.icm.CAvg
	if mpu.GAError != nil {
		// Ignores worthless error
		if !strings.Contains(mpu.GAError.Error(), "No new accel/gyro values") {
			return nil, fmt.Errorf("error reading icm20948 values: %w", mpu.GAError)
		}
	}
	x, y, z := mpu.G1, mpu.G2, mpu.G3
	if dev.debug {
		log.Printf("x=% .0f °/s \t y=% .0f °/s \t z=% .0f °/s \n", x, y, z)
	}
	point = influxdb2.NewPoint(
		"gyro", // Measurement
		map[string]string{ // Tags
			"unit": "deg/s",
		},
		map[string]any{ // Fields
			"x": x,
			"y": y,
			"z": z,
		},
		now, // Timestamp
	)
	return
}
