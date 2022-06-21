ARG ALPINE_VERSION

# Build jmx-exporter-javaagent
FROM maven:3-jdk-8 as jmx-exporter

ENV JMX_EXPORTER_VERSION 0.17.0

RUN git clone -b parent-${JMX_EXPORTER_VERSION} https://github.com/prometheus/jmx_exporter \
  && cd jmx_exporter \
  && mvn clean package -DskipTests


# Build nexus3-repositoru-apt
FROM maven:3-jdk-8 as nexus3-keycloak-plugin

ENV NEXUS_KEYCLOAK_PLUGIN_VERSION 18.0.1

RUN git clone -b ${NEXUS_KEYCLOAK_PLUGIN_VERSION} https://github.com/k8s-by/nexus3-keycloak-plugin \
  && cd nexus3-keycloak-plugin \
  && mvn clean package -DskipTests


############################################################################

# Main Image
FROM alpine:${ALPINE_VERSION}

ARG VERSION

ENV NEXUS_VERSION ${VERSION}
ENV NEXUS_DOWNLOAD_URL "https://download.sonatype.com/nexus/3"
ENV NEXUS_TARBALL_URL "${NEXUS_DOWNLOAD_URL}/nexus-${NEXUS_VERSION}-unix.tar.gz"
ENV NEXUS_TARBALL_ASC_URL "${NEXUS_DOWNLOAD_URL}/nexus-${NEXUS_VERSION}-unix.tar.gz.asc"
ENV GPG_KEY 0374CF2E8DD1BDFD

ENV SONATYPE_DIR /opt/sonatype
ENV NEXUS_HOME "${SONATYPE_DIR}/nexus"
ENV NEXUS_DATA /nexus-data
ENV NEXUS_CONFIG /nexus-config
ENV NEXUS_CONTEXT ''
ENV SONATYPE_WORK ${SONATYPE_DIR}/sonatype-work

ENV JMX_EXPORTER_VERSION 0.17.0
ENV NEXUS_KEYCLOAK_PLUGIN_VERSION 18.0.1

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

# Install nexus
RUN apk add --no-cache --update bash ca-certificates runit su-exec util-linux
RUN apk add --no-cache openjdk8-jre \
  && apk add --no-cache -t .build-deps wget gnupg openssl  \
  && cd /tmp \
  && echo "===> Installing Nexus ${NEXUS_VERSION}..." \
  && wget -O nexus.tar.gz $NEXUS_TARBALL_URL; \
  wget -O nexus.tar.gz.asc $NEXUS_TARBALL_ASC_URL; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys $GPG_KEY; \
    gpg --batch --verify nexus.tar.gz.asc nexus.tar.gz; \
    rm -r $GNUPGHOME nexus.tar.gz.asc; \
  tar -xf nexus.tar.gz \
  && mkdir -p $SONATYPE_DIR \
  && mv nexus-$NEXUS_VERSION $NEXUS_HOME \
  && cd $NEXUS_HOME \
  && ls -las \
  && adduser -h $NEXUS_DATA -DH -s /sbin/nologin nexus \
  && chown -R nexus:nexus $NEXUS_HOME \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

# Configure nexus
RUN sed \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties \
  && sed \
    -e '/^-Xms/d' \
    -e '/^-Xmx/d' \
    -i ${NEXUS_HOME}/bin/nexus.vmoptions

RUN mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} \
  && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 \
  && chown -R nexus:nexus ${NEXUS_DATA}

# Replace logback configuration
COPY logback.xml ${NEXUS_HOME}/etc/logback/logback.xml
COPY logback-access.xml ${NEXUS_HOME}/etc/logback/logback-access.xml

# Copy runnable script
COPY run /etc/service/nexus/run

# and make it executable
RUN chmod +x /etc/service/nexus/run

## Copy jmx-exportet-javaagent
COPY --from=jmx-exporter  /jmx_exporter/jmx_prometheus_javaagent/target/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar ${NEXUS_HOME}/jmx-exporter/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar
COPY jmx-exporter-config.yaml ${NEXUS_CONFIG}/jmx-exporter-config.yaml


## Copy nexus3-keycloak-plugin
COPY --from=nexus3-keycloak-plugin /nexus3-keycloak-plugin/target/nexus3-keycloak-plugin-${NEXUS_KEYCLOAK_PLUGIN_VERSION}.jar ${NEXUS_HOME}/system/org/github/flytreeleft/nexus3-keycloak-plugin/${NEXUS_KEYCLOAK_PLUGIN_VERSION}/nexus3-keycloak-plugin-${NEXUS_KEYCLOAK_PLUGIN_VERSION}.jar
RUN echo "mvn\\:org.github.flytreeleft/nexus3-keycloak-plugin/${NEXUS_KEYCLOAK_PLUGIN_VERSION} = 200" >> ${NEXUS_HOME}/etc/karaf/startup.properties


VOLUME ${NEXUS_DATA}

EXPOSE 8081

WORKDIR ${NEXUS_HOME}

RUN chown -R nexus:nexus ${SONATYPE_DIR}
RUN chown -R nexus:nexus ${NEXUS_DATA}

USER nexus

ENV INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -javaagent:${NEXUS_HOME}/jmx-exporter/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar=8180:/nexus-config/jmx-exporter-config.yaml"

#CMD ["/sbin/runsvdir", "-P", "/etc/service"]
CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
