export GO111MODULE=on

all: bin/benchmarker bin/benchmark-worker bin/payment bin/shipment

bin/benchmarker: cmd/bench/main.go bench/**/*.go
	go build -o bin/benchmarker cmd/bench/main.go
	GOOS=linux go build -o bin/linux/benchmarker cmd/bench/main.go

bin/benchmark-worker: cmd/bench-worker/main.go
	go build -o bin/benchmark-worker cmd/bench-worker/main.go
	GOOS=linux go build -o bin/linux/benchmark-worker cmd/bench-worker/main.go

bin/payment: cmd/payment/main.go bench/server/*.go
	go build -o bin/payment cmd/payment/main.go
	GOOS=linux go build -o bin/linux/payment cmd/payment/main.go

bin/shipment: cmd/shipment/main.go bench/server/*.go
	go build -o bin/shipment cmd/shipment/main.go
	GOOS=linux go build -o bin/linux/shipment cmd/shipment/main.go

vet:
	go vet ./...

errcheck:
	errcheck ./...

staticcheck:
	staticcheck -checks="all,-ST1000" ./...

clean:
	rm -rf bin/*

restartapi:
	docker-compose stop api
	docker rm $(shell docker ps -aq -f 'ancestor=isucon9-qualify_api')
	docker-compose up -d api

restartdb:
	docker-compose stop db
	docker rm $(shell docker ps -aq -f 'ancestor=mysql')
	docker-compose up -d db
