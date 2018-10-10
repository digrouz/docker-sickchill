# docker-sickrage
Install sickrage into a Linux container

![sickrage](https://sickrage.github.io/images/logo.png)

## Tag
Several tag are available:
* latest: see alpine3.8
* centos7: [centos7/Dokerfile](https://github.com/digrouz/docker-sickrage/blob/centos7/Dockerfile)
* alpine3.6: [alpine3.6/Dockerfile](https://github.com/digrouz/docker-sickrage/blob/alpine3.6/Dockerfile)
* alpine3.7: [alpine3.7/Dockerfile](https://github.com/digrouz/docker-sickrage/blob/alpine3.7/Dockerfile)
* alpine3.8: [alpine3.8/Dockerfile](https://github.com/digrouz/docker-sickrage/blob/alpine3.8/Dockerfile)

## Description

SickRage is an automatic Video Library Manager for TV Shows. It watches for new episodes of your favorite shows, and when they are posted it does its magic: automatic torrent/nzb searching, downloading, and processing at the qualities you want.

https://sickrage.github.io/

## Usage
    docker create --name=sickrage  \
      -v /etc/localtime:/etc/localtime:ro \ 
      -v <path to config>:/config \
      -v <path to downloads>:/downloads \ 
      -v <path to show library>:/tv \
      -v <path to anime library>:/animes \ 
      -e DOCKUID=<UID default:10000> \
      -e DOCKGID=<GID default:10000> \
      -e DOCKUPGRADE=<0|1> \
      -p 8081:8081 digrouz/sickrage:alpine3.7

## Environment Variables

When you start the `sickrage` image, you can adjust the configuration of the `sickrage` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10000`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10000`.

### `DOCKUPGRADE`

This variable is not mandatory and specifies if the container has to launch software update at startup or not. Valid values are `0` and `1`. It has default value `0`.

## Notes

* The docker entrypoint can upgrade operating system at each startup. To enable this feature, just add `-e DOCKUPGRADE=1` at container creation.

## Issues

If you encounter an issue please open a ticket at [github](https://github.com/digrouz/docker-sickrage/issues)
