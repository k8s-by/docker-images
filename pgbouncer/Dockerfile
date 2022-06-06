ARG VERSION
FROM alpine:3.16

ARG VERSION
ENV PGBOUNCER_VERSION ${VERSION}

RUN apk --update --no-cache add udns \
        autoconf \
        autoconf-doc \
        automake \
        udns-dev \        
        curl \
        gcc \
        libc-dev \
        libevent \
        libevent-dev \
        libtool \
        make \
        openssl-dev \
        ca-certificates \
        pkgconf \
  && curl -Lo  "/tmp/pgbouncer.tar.gz" "https://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz" \
  && cd /tmp && mkdir /tmp/pgbouncer && tar -zxvf pgbouncer.tar.gz -C /tmp/pgbouncer --strip-components 1 \
  && ( cd /tmp/pgbouncer && ./configure --prefix=/usr --with-udns && make \
  && mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer \
     && cp pgbouncer /usr/bin \
     && cp etc/pgbouncer.ini /etc/pgbouncer.ini.example \
     && cp etc/userlist.txt /etc/pgbouncer/userlist.txt.example ) \
  && addgroup  -g 70 -S postgres 2>/dev/null \
  && adduser -u 70 -S -D -H -h /var/lib/postgresql -g "Postgres user" -s /bin/sh -G postgres postgres 2>/dev/null \
  && chown -R postgres /var/run/pgbouncer /etc/pgbouncer \
  && rm -rf /tmp/pgbouncer  \  
  && apk del --purge autoconf autoconf-doc automake udns-dev curl gcc libc-dev libevent-dev libtool make openssl-dev pkgconfig

COPY entrypoint.sh /opt/pgbouncer/entrypoint.sh

USER postgres

WORKDIR /opt/pgbouncer
ENTRYPOINT ["/opt/pgbouncer/entrypoint.sh"]

