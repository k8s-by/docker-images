ARG VERSION
ARG ALPINE_VERSION

FROM golang:1.17 AS builder

ADD . /redis-sentinel-proxy/
WORKDIR /redis-sentinel-proxy
RUN go mod init redis-sentinel-proxy && \
     CGO_ENABLED=0 go build -o redis-sentinel-proxy .

FROM alpine:$ALPINE_VERSION

COPY --from=builder /redis-sentinel-proxy/redis-sentinel-proxy /usr/local/bin/redis-sentinel-proxy


ENTRYPOINT ["/usr/local/bin/redis-sentinel-proxy"]

CMD ["-master", "mymaster"]