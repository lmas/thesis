package sensors

import (
	"time"

	"github.com/influxdata/influxdb-client-go/v2/api/write"
)

type Sensor interface {
	Close() error
	NewSample(time.Time) (*write.Point, error)
}
