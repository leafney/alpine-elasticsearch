FROM alpine:3.5
MAINTAINER leafney "babycoolzx@126.com"

RUN echo "http://dl-4.alpinelinux.org/alpine/v3.5/main" >> /etc/apk/repositories && \
	echo "http://dl-4.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories

# from https://github.com/docker-library/openjdk/blob/master/8-jdk/alpine/Dockerfile
# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker_java_home \
	&& chmod +x /usr/local/bin/docker_java_home

ENV JAVA_ALPINE_VERSION=8.121.13-r0 \
	ELASTICSEARCH_VERSION=2.4.1 \
	IK_ANALYSIS_VERSION=1.10.1 \
	ELASTICSEARCH_DIR=/usr/share/elasticsearch \
	ELASTICSEARCH_DATA=/app \
	JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

ENV PATH ${ELASTICSEARCH_DIR}/bin:$PATH
ENV PATH /usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin:$PATH

RUN set -x && \
	apk update && \
	apk add curl \
	openjdk8="$JAVA_ALPINE_VERSION" \
	openssl && \
	addgroup -S elasticsearch && \
	adduser -S -G elasticsearch elasticsearch && \
	mkdir -p ${ELASTICSEARCH_DIR} && \
	[ "$JAVA_HOME" = "$(docker_java_home)" ]

RUN curl -sSL https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ELASTICSEARCH_VERSION}/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz | tar -zxv -C ${ELASTICSEARCH_DIR} --strip-components 1 && \
	mkdir -p ${ELASTICSEARCH_DIR}/data ${ELASTICSEARCH_DIR}/logs ${ELASTICSEARCH_DIR}/config/scripts && \
	mkdir -p ${ELASTICSEARCH_DATA}/data ${ELASTICSEARCH_DATA}/logs ${ELASTICSEARCH_DATA}/config/scripts

# use gosu
RUN curl -o /usr/local/bin/gosu -sSL https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 && \
	chmod +x /usr/local/bin/gosu

# set timezone
RUN apk add ca-certificates tzdata && \
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" > /etc/timezone && \
	rm -rf /var/cache/apk/*

# COPY ./config ${ELASTICSEARCH_DATA}/config

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

VOLUME ["${ELASTICSEARCH_DATA}"]

EXPOSE 9200 9300

CMD ["gosu","elasticsearch","elasticsearch","--path.conf=${ELASTICSEARCH_DATA}/config"]