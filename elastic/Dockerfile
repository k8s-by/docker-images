ARG VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:$VERSION

ARG VERSION

ENV VERSION ${VERSION}

RUN bin/elasticsearch-plugin install -b \
       https://github.com/vvanholl/elasticsearch-prometheus-exporter/releases/download/$VERSION.0/prometheus-exporter-$VERSION.0.zip \
       https://artifacts.elastic.co/downloads/elasticsearch-plugins/repository-s3/repository-s3-$VERSION.zip
