export GO111MODULE=on

all: bin/benchmarker bin/benchmark-worker bin/payment bin/shipment

bin/benchmarker: cmd/bench/main.go bench/**/*.go
	go build -o bin/benchmarker cmd/bench/main.go
	GOOS=linux go build -o deploy/benchmarker/benchmarker cmd/bench/main.go

bin/benchmark-worker: cmd/bench-worker/main.go
	go build -o bin/benchmark-worker cmd/bench-worker/main.go
	GOOS=linux go build -o bin/linux/benchmark-worker cmd/bench-worker/main.go

bin/payment: cmd/payment/main.go bench/server/*.go
	go build -o bin/payment cmd/payment/main.go
	GOOS=linux go build -o deploy/payment/payment cmd/payment/main.go

bin/shipment: cmd/shipment/main.go bench/server/*.go
	go build -o bin/shipment cmd/shipment/main.go
	GOOS=linux go build -o deploy/shipment/shipment cmd/shipment/main.go

vet:
	go vet ./...

errcheck:
	errcheck ./...

staticcheck:
	staticcheck -checks="all,-ST1000" ./...

clean:
	rm -rf bin/*
	rm -rf deploy/benchmarker/benchmarker
	rm -rf deploy/payment/payment
	rm -rf deploy/shipment/shipment


restartall: restartdb restartapi restarth2o

restarth2o:
	docker-compose stop h2o
	docker rm $(shell docker ps -aq -f 'ancestor=lkwg82/h2o-http2-server')
	docker-compose up -d h2o

restartapi:
	docker-compose stop api
	docker rm $(shell docker ps -aq -f 'ancestor=isucon9-qualify_api')
	docker-compose up -d api

restartdb:
	docker-compose stop db
	docker rm $(shell docker ps -aq -f 'ancestor=mysql')
	docker-compose up -d db

rmall: rmdb rmapi rmh2o

rmh2o:
	docker-compose stop h2o
	docker rm $(shell docker ps -aq -f 'ancestor=lkwg82/h2o-http2-server')

rmapi:
	docker-compose stop api
	docker rm $(shell docker ps -aq -f 'ancestor=isucon9-qualify_api')

rmdb:
	docker-compose stop db
	docker rm $(shell docker ps -aq -f 'ancestor=mysql')

benchmarker:
	docker-compose run benchmarker /benchmarker -target-url http://h2o:8000 -payment-url http://payment:5555 -shipment-url http://shipment:7000
