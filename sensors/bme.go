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
	"log"
	"time"

	"code.larus.se/lmas/thesis/damp"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api/write"
	"periph.io/x/conn/v3/i2c"
	"periph.io/x/conn/v3/i2c/i2creg"
	"periph.io/x/conn/v3/physic"
	"periph.io/x/devices/v3/bmxx80"
	"periph.io/x/host/v3"
)

const (
	bmePeriod int = 1000
	bmeBuffer int = 1024
	bmeSeq    int = 8
	bmeTrain  int = 512
)

type BME struct {
	debug bool
	bus   i2c.BusCloser
	bme   *bmxx80.Dev
	temp  *damp.StreamDAMP
	pres  *damp.StreamDAMP
	humi  *damp.StreamDAMP
}

func NewBME(debug bool) (dev *BME, err error) {
	temp, err := damp.NewStreamDAMP(bmeBuffer, bmeSeq, bmeTrain, false)
	if err != nil {
		return nil, err
	}
	pres, err := damp.NewStreamDAMP(bmeBuffer, bmeSeq, bmeTrain, false)
	if err != nil {
		return nil, err
	}
	humi, err := damp.NewStreamDAMP(bmeBuffer, bmeSeq, bmeTrain, false)
	if err != nil {
		return nil, err
	}
	dev = &BME{
		debug: debug,
		temp:  temp,
		pres:  pres,
		humi:  humi,
	}

	if _, err = host.Init(); err != nil {
		return nil, err
	}
	dev.bus, err = i2creg.Open("")
	if err != nil {
		return nil, err
	}
	dev.bme, err = bmxx80.NewI2C(dev.bus, 0x76, &bmxx80.Opts{
		Temperature: bmxx80.O1x,
		Pressure:    bmxx80.O1x,
		Humidity:    bmxx80.O1x,
		Filter:      bmxx80.NoFilter,
	})
	if err != nil {
		return nil, err
	}

	if debug {
		log.Printf("bme sensor\t sequence size=%v\t training until=%v\n",
			time.Duration(bmeSeq)*time.Second,
			time.Now().Add(time.Duration(bmeTrain)*time.Second),
		)
	}
	return
}

func (dev *BME) Close() error {
	dev.bme.Halt()
	dev.bus.Close()
	return nil
}

func (dev *BME) PeriodTime() time.Duration {
	return time.Duration(bmePeriod) * time.Millisecond
}

func (dev *BME) NewSample(now time.Time) (point *write.Point, err error) {
	// // Read temperature from the sensor:
	var env physic.Env
	if err = dev.bme.Sense(&env); err != nil {
		log.Fatal(err)
	}

	temp := env.Temperature.Celsius()
	pres := float64(env.Pressure) / float64(physic.Pascal)
	humi := float64(env.Humidity) / float64(physic.PercentRH)
	tempdist := dev.temp.Push(temp)
	presdist := dev.pres.Push(pres)
	humidist := dev.humi.Push(humi)

	if dev.debug {
		log.Printf("temp=%f °C (%f)\t pres=%f kPa (%f)\t humi=%f %%rH (%f)\n", temp, tempdist, pres, presdist, humi, humidist)
	}
	point = influxdb2.NewPoint(
		"bme",             // Measurement
		map[string]string{ // Tags
			// "unit": "",
		},
		map[string]any{ // Fields
			"temperature":         temp,
			"temperature_discord": tempdist,
			"pressure":            pres,
			"pressure_discord":    presdist,
			"humidity":            humi,
			"humidity_discord":    humidist,
		},
		now, // Timestamp
	)
	return
}
