# vim:set ft=dockerfile:
FROM alpine:latest
MAINTAINER DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' \
    BLDAPKREQ='make gcc g++ python-dev py-pip git openssl-dev libffi-dev' \
    RUNAPKREQ='ca-certificates python py-libxml2 py-lxml unrar' \
    RUNPIPREQ='pyopenssl cheetah requirements' \

### Install Application
RUN apk --no-cache upgrade && \
    apk --no-cache add \
      ${BLDAPKREQ} \
      ${RUNAPKREQ} && \
    pip --no-cache-dir install --upgrade setuptools && \
    pip --no-cache-dir install --upgrade ${RUNPIPREQ} && \
    git clone --depth 1 https://github.com/SickRage/SickRage.git /opt/sickrage && \
    apk --no-cache del ${BLDAPKREQ} && \
    rm -rf /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*

### Volume
VOLUME ["/config", "/downloads", "/cache"]

### Expose ports
EXPOSE 8081

### Running User
USER sickrage

### Start Sickrage
