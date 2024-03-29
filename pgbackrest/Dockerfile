ARG ALPINE_VERSION

FROM alpine:$ALPINE_VERSION

ARG VERSION


ARG BACKREST_COMPLETION_VERSION
ARG REPO_BUILD_TAG

ENV BACKREST_VERSION=$VERSION

ENV TZ="Etc/UTC" \
    BACKREST_USER="pgbackrest" \
    BACKREST_UID=2001 \
    BACKREST_GROUP="pgbackrest" \
    BACKREST_GID=2001 \
    BACKREST_HOST_TYPE="ssh" \
    BACKREST_TLS_WAIT=15 \
    BACKREST_TLS_SERVER="disable"

RUN apk add --no-cache --update \
        bash \
        shadow \
        postgresql-client \
        ca-certificates \
        libxml2 \
        su-exec \
        procps \
        tzdata \
        openssh \
        libbz2 \
        lz4-libs \
        zstd-libs \
    && apk --update add --virtual .backrest-build \
        build-base \
        wget \
        make \
        gcc \
        libpq-dev \
        openssl-dev \
        libxml2-dev \
        pkgconfig \
        lz4-dev \
        zstd-dev \
        bzip2-dev \
        zlib-dev \
        yaml-dev \
    && ln -s /sbin/su-exec /usr/local/bin/gosu \
    && wget https://github.com/pgbackrest/pgbackrest/archive/release/${BACKREST_VERSION}.tar.gz -O /tmp/pgbackrest-${BACKREST_VERSION}.tar.gz \
    && tar -xzf /tmp/pgbackrest-${BACKREST_VERSION}.tar.gz -C /tmp \
    && mv /tmp/pgbackrest-release-${BACKREST_VERSION} /tmp/pgbackrest-release \
    && cd /tmp/pgbackrest-release/src \
    && ./configure \
    && make \
    && cp /tmp/pgbackrest-release/src/pgbackrest /usr/bin/pgbackrest \
    && groupadd --gid ${BACKREST_GID} ${BACKREST_GROUP} \
    && useradd --shell /bin/bash --uid ${BACKREST_UID} --gid ${BACKREST_GID} -m ${BACKREST_USER} \
    && wget https://github.com/woblerr/pgbackrest-bash-completion/archive/${BACKREST_COMPLETION_VERSION}.tar.gz -O /tmp/pgbackrest-bash-completion-${BACKREST_COMPLETION_VERSION}.tar.gz \
    && tar -xzf /tmp/pgbackrest-bash-completion-${BACKREST_COMPLETION_VERSION}.tar.gz -C /tmp \
    && mv /tmp/pgbackrest-bash-completion-$(echo ${BACKREST_COMPLETION_VERSION} | tr -d v) /tmp/pgbackrest-bash-completion \
    && mkdir -p -m 750 /var/log/pgbackrest \
        /home/${BACKREST_USER}/.bash_completion.d \
        /var/lib/pgbackrest \
        /var/spool/pgbackrest \
        /etc/pgbackrest \
        /etc/pgbackrest/conf.d \
        /etc/pgbackrest/cert \
    && cp /tmp/pgbackrest-bash-completion/pgbackrest-completion.sh /home/${BACKREST_USER}/.bash_completion.d/pgbackrest-completion.sh \
    && touch /etc/pgbackrest/pgbackrest.conf \
    && chmod 640 /etc/pgbackrest/pgbackrest.conf \
    && chown -R ${BACKREST_USER}:${BACKREST_GROUP} \
        /home/${BACKREST_USER}/.bash_completion.d \
        /var/log/pgbackrest \
        /var/lib/pgbackrest \
        /var/spool/pgbackrest \
        /etc/pgbackrest \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && rm -rf \
        /tmp/pgbackrest-release \
        /tmp/pgbackrest-bash-completion \
    && apk del .backrest-build \
    && rm -rf /var/cache/apk/*

COPY files/entrypoint.sh /entrypoint.sh

LABEL \
    org.opencontainers.image.version="${REPO_BUILD_TAG}" \
    org.opencontainers.image.source="https://github.com/woblerr/docker-pgbackrest"

ENTRYPOINT ["/entrypoint.sh"]

CMD ["pgbackrest", "version"]