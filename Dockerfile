FROM alpine:3.8
LABEL maintainer "DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>"

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' 

### Install Application
RUN apk --no-cache upgrade && \
    apk add --no-cache --virtual=build-deps \
      make \
      gcc \
      g++ \
      python-dev \
      libxslt-dev \
      linux-headers \
      libressl-dev \
      libffi-dev && \
    apk add --no-cache --virtual=run-deps \
      bash \
      ca-certificates \
      python \ 
      py2-pip \
      libffi \
      libxslt \
      nodejs \
      unrar  \
      su-exec \
      git && \
    git clone --depth 1 https://git.sickrage.ca/SiCKRAGE/sickrage.git /opt/sickrage && \
    pip --no-cache-dir install --upgrade setuptools pip && \
    pip --no-cache-dir install --upgrade -r /opt/sickrage/requirements.txt && \
    apk del --no-cache --purge \
      build-deps  && \
    rm -rf /opt/sickrage/.git* \
           /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*

### Volume
VOLUME ["/config", "/downloads", "/tv", "/animes"]

### Expose ports
EXPOSE 8081

### Running User: not used, managed by docker-entrypoint.sh
#USER sickrage

### Start Sickrage
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sickrage"]
