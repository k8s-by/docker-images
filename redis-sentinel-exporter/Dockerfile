FROM golang:1.17 as builder

ARG VERSION

WORKDIR /go

RUN git clone -b v${VERSION} https://github.com/alex-egorov/redis-sentinel-exporter \
    && ( cd redis-sentinel-exporter && go mod tidy &&  go build .) \
    && pwd && ls -la  redis-sentinel-exporter



FROM scratch
COPY --from=builder /go/redis-sentinel-exporter/redis-sentinel-exporter /redis-sentinel-exporter
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/


ENTRYPOINT ["/redis-sentinel-exporter"]