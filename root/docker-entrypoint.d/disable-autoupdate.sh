#!/usr/bin/env bash


. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

DockLog "Disabling auto_update in /config/config.ini"
sed -i \
  -e 's|auto_update =.*|auto_update = 0|g' \
/config/config.ini
