FROM golang:1.17 as builder

ARG VERSION

WORKDIR /go

RUN git clone -b v$VERSION https://github.com/alex-egorov/redis-sentinel-exporter
RUN cd redis-sentinel-exporter && ls -la && go mod tidy \
  && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /redis-sentinel-exporter \
          -ldflags  "-s -w -extldflags \"-static\" \
          -X main.BuildVersion=v${VERSION} -X main.BuildCommitSha=$SHA1 -X main.BuildDate=$(date +%F-%T)" .


FROM scratch
COPY --from=builder /redis-sentinel-exporter /redis-sentinel-exporter
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/nsswitch.conf /etc/nsswitch.conf

EXPOSE 9355
ENTRYPOINT ["/redis-sentinel-exporter"]