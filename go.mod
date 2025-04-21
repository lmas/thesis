module code.larus.se/lmas/thesis

go 1.24.2

require (
	github.com/JenswBE/golang-tsl2591 v0.0.0-20230415120237-14a517a709e8
	github.com/influxdata/influxdb-client-go/v2 v2.14.0
	github.com/joho/godotenv v1.5.1
	github.com/kidoman/embd v0.0.0-20170508013040-d3d8c0c5c68d
	github.com/mjibson/go-dsp v0.0.0-20180508042940-11479a337f12
	github.com/stratux/goflying v0.0.0-20250123172850-dd059ec48194
)

require (
	github.com/apapsch/go-jsonmerge/v2 v2.0.0 // indirect
	github.com/golang/glog v0.0.0-20160126235308-23def4e6c14b // indirect
	github.com/google/uuid v1.3.1 // indirect
	github.com/influxdata/line-protocol v0.0.0-20200327222509-2487e7298839 // indirect
	github.com/oapi-codegen/runtime v1.0.0 // indirect
	golang.org/x/net v0.23.0 // indirect
	periph.io/x/conn/v3 v3.7.0 // indirect
	periph.io/x/host/v3 v3.8.0 // indirect
)

replace github.com/kidoman/embd v0.0.0-20170508013040-d3d8c0c5c68d => github.com/lmas/embd v0.0.0-20250421112644-8f3ea197cda7
