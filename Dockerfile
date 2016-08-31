# vim:set ft=dockerfile:
FROM alpine:latest
MAINTAINER DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' \
    BLDAPKREQ='make gcc g++ python-dev py-pip git openssl-dev libffi-dev gnupg' \
    RUNAPKREQ='ca-certificates python py-libxml2 py-lxml unrar openssl' \
    RUNPIPREQ='pyopenssl cheetah requirements' \
    GOSU_VERSION='1.9'
    

### Install Application
RUN apk --no-cache upgrade && \
    apk --no-cache add \
      ${BLDAPKREQ} \
      ${RUNAPKREQ} && \
    pip --no-cache-dir install --upgrade setuptools && \
    pip --no-cache-dir install --upgrade ${RUNPIPREQ} && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)"  && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    git clone --depth 1 https://github.com/SickRage/SickRage.git /opt/sickrage && \
    gosu nobody true && \
    apk --no-cache del ${BLDAPKREQ} && \
    rm -rf /usr/local/bin/gosu.asc \
           /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*

### Volume
VOLUME ["/config", "/downloads", "/cache"]

### Expose ports
EXPOSE 8081

### Running User: not used, managed by docker-entrypoint.sh
#USER sickrage

### Start Sickrage
