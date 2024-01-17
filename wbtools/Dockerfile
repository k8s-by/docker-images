ARG VERSION
ARG DOCKER_REGISTRY

FROM alpine:$ALPINE_VERSION

ENV USER=wbuser
ENV UID=1001
ENV GID=1001

USER root

RUN apk update \
    && apk upgrade \
    && apk --no-cache add libcap openssh-client wget curl rsync jq nano bash nmap busybox-extras bind-tools fio \
    \
    && addgroup -S -g $GID $USER && adduser \
        --disabled-password \
        --gecos "" \
        --home "/home/$USER" \
        --ingroup "$USER" \
        --no-create-home \
        --uid "$UID" \
        "$USER" \
    \
    && mkdir -p /home/$USER \
    && chown $USER /home/$USER


USER $USER

WORKDIR /home/$USER
