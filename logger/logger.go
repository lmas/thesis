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
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/joho/godotenv"
)

const logPeriod int = 1000

var debug = flag.Bool("debug", false, "Print debug info")

func main() {
	flag.Parse()
	db, err := openInfluxdb()
	if err != nil {
		log.Fatalln("Error connecting to influxdb:", err)
	}
	defer db.Close()

	light, err := sensors.NewLight(*debug)
	if err != nil {
		log.Fatalln("Error connecting light sensor:", err)
	}
	defer light.Close()
	gyro, err := sensors.NewGyro(*debug)
	if err != nil {
		log.Fatalln("Error connecting gyro sensor:", err)
	}
	defer gyro.Close()
	list := []sensors.Sensor{
		light,
		gyro,
	}

	log.Println("Logging data...")
	if err := loop(db, list); err != nil {
		log.Fatalln("Error logging data:", err)
	}
	log.Println("Bye")
}

const envFile string = ".logger.env"

// influxdb defaults to 5000, source:
// https://github.com/influxdata/influxdb-client-go/blob/master/api/write/options.go
const batchSize int = 2 * 900 // 1 point/second * 60 seconds * 15 minutes

func openInfluxdb() (client influxdb2.Client, err error) {
	if err := godotenv.Load(envFile); err != nil {
		return nil, fmt.Errorf("Error loading env file: ", err)
	}
	client = influxdb2.NewClientWithOptions(
		os.Getenv("host"), os.Getenv("token"),
		influxdb2.DefaultOptions().SetHTTPClient(http.DefaultClient).SetBatchSize(uint(batchSize)),
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

func loop(db influxdb2.Client, list []sensors.Sensor) error {
	writer := db.WriteAPI(
		os.Getenv("org"), os.Getenv("bucket"),
	)
	errChan := writer.Errors()
	ticker := time.Tick(time.Duration(logPeriod) * time.Millisecond)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT) // Traps ctrl+c

	for {
		// Drain any writer errors (NOTE: MUST BE DONE BEFORE A WRITE!)
		for len(errChan) > 0 {
			err := <-errChan
			return fmt.Errorf("error from writer: ", err)
		}

		now := time.Now().UTC()
		for _, s := range list {
			p, err := s.NewSample(now)
			if err != nil {
				log.Println("Sample sensor:", err)
				continue
			}
			writer.WritePoint(p)
		}

		select {
		case <-ticker: // nop
		case <-sigChan:
			writer.Flush()
			return nil
		}
	}
}
