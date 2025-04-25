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
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"code.larus.se/lmas/thesis/sensors"
	"github.com/BurntSushi/toml"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api"
)

var debug = flag.Bool("debug", false, "Print debug info")

type config struct {
	Influx  confInflux
	Sensors map[string]confSensor
}

type confInflux struct {
	Host   string
	Token  string
	Org    string
	Bucket string
}

type confSensor struct {
	Period    int
	MaxSize   int
	SeqSize   int
	TrainSize int
}

func main() {
	flag.Parse()
	var conf config
	_, err := toml.DecodeFile("logger.toml", &conf)
	if err != nil {
		log.Fatalln("Error reading config file:", err)
	}

	db, err := openInfluxdb(conf)
	if err != nil {
		log.Fatalln("Error connecting to influxdb:", err)
	}
	defer db.Close()

	light, err := sensors.NewLight(*debug)
	if err != nil {
		log.Fatalln("Error connecting light sensor:", err)
	}
	defer light.Close()
	bme, err := sensors.NewBME(*debug)
	if err != nil {
		log.Fatalln("Error connecting bme sensor:", err)
	}
	defer bme.Close()
	list := []sensors.Sensor{
		light,
		bme,
	}

	log.Println("Logging data...")
	if err := loop(conf, db, list); err != nil {
		log.Fatalln("Error logging data:", err)
	}
	log.Println("Bye")
}

const envFile string = ".logger.env"

// influxdb defaults to 5000, source:
// https://github.com/influxdata/influxdb-client-go/blob/master/api/write/options.go

func openInfluxdb(conf config) (client influxdb2.Client, err error) {
	client = influxdb2.NewClientWithOptions(
		conf.Influx.Host, conf.Influx.Token,
		influxdb2.DefaultOptions().SetHTTPClient(http.DefaultClient),
	)

	// Verify it's running
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	open, err := client.Ping(ctx)
	cancel()
	if err != nil {
		return nil, fmt.Errorf("Error connecting to influxdb: ", err)
	}
	if !open {
		return nil, fmt.Errorf("Influxdb not running?")
	}

	// All ok
	return
}

func loop(conf config, db influxdb2.Client, list []sensors.Sensor) error {
	writer := db.WriteAPI(
		conf.Influx.Org, conf.Influx.Bucket,
	)
	errChan := writer.Errors()
	flusher := time.Tick(1 * time.Minute)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT) // Traps ctrl+c

	var chClose []chan bool
	for _, dev := range list {
		c := make(chan bool, 1)
		chClose = append(chClose, c)
		go samplingLoop(writer, c, dev)
	}

	for {
		// Drain any writer errors (NOTE: MUST BE DONE BEFORE A WRITE!)
		for len(errChan) > 0 {
			err := <-errChan
			log.Println("error from writer:", err)
		}
		select {
		case <-flusher:
			writer.Flush()
		case <-sigChan:
			for _, c := range chClose {
				close(c)
			}
			// TODO: should wait for goroutines to close properly (with waitgroups)
			writer.Flush()
			return nil
		}
	}
}

func samplingLoop(w api.WriteAPI, c chan bool, dev sensors.Sensor) {
	ticker := time.Tick(dev.PeriodTime())
	for {
		select {
		case <-c:
			return
		case <-ticker:
			now := time.Now()
			p, err := dev.NewSample(now)
			if err != nil {
				log.Println("Sample sensor:", err)
				continue
			}
			w.WritePoint(p)
		}
	}
}
