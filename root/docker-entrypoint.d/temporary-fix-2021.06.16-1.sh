#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"


if [ "${SICKCHILL_VERSION}" == '2021.06.16-1' ]
then
  DockLog "temporary fixing parser.py on version 2021.06.16-1"
  curl -sL https://raw.githubusercontent.com/SickChill/SickChill/master/sickchill/oldbeard/name_parser/parser.py -o /opt/sickchill/sickchill/oldbeard/name_parser/parser.py
fi
