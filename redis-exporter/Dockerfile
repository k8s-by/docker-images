FROM golang:1.17 as builder

ARG VERSION

RUN git clone -b v${VERSION} https://github.com/oliver006/redis_exporter \
    && cd redis_exporter \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /redis-exporter \
           -ldflags  "-s -w -extldflags \"-static\" \
           -X main.BuildVersion=v${VERSION} -X main.BuildCommitSha=$SHA1 -X main.BuildDate=$(date +%F-%T)" .


FROM scratch
COPY --from=builder /redis-exporter /redis-exporter
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /etc/nsswitch.conf /etc/nsswitch.conf


USER 59000:59000

EXPOSE     9121
ENTRYPOINT [ "/redis-exporter" ]