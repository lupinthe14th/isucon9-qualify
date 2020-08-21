FROM golang:1.14

RUN go get -u -v github.com/oxequa/realize

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     default-mysql-client \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/*
