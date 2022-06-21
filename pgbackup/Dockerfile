ARG DOCKER_REGISTRY
ARG VERSION
FROM $DOCKER_REGISTRY/postgres-client:$VERSION

ENV HOME_PATH "/opt/postgres"
ENV EDITOR "nano"

WORKDIR ${HOME_PATH}

RUN apk --no-cache add wget curl rsync jq nano bash python3 py3-pip postgresql12-client postgresql12-contrib groff \
       nmap busybox-extras \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir awscli \
    && rm -rf /var/cache/apk/*


COPY pgbackup.sh /opt/postgres/


USER postgres:postgres

