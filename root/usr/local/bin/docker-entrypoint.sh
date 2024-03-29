#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

AutoUpgrade
ConfigureUser

if [ "$1" == 'sickchill' ]; then
  DockLog "Fixing permissions on /config /opt/sickchill"
  chown -R "${MYUSER}":"${MYUSER}" /config /opt/sickchill
  chmod -R g+w /config /opt/sickchill
  RunDropletEntrypoint
  DockLog "Starting app: ${1}"
  . /opt/sickchill/bin/activate
  exec su-exec "${MYUSER}" python3 /opt/sickchill/bin/SickChill --nolaunch --datadir=/config/ --config=/config/config.ini
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi

