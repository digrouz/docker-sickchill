#!/bin/sh
set -e
local MYUSER="sickrage"
local MYGID="10000"
local MYUID="10000"

#Managing group
if [ -n "${DOCKGID}" ]; then
  MYGID="${DOCKGID}"
fi
/usr/sbin/addgroup --system -g "${MYGID}" "${MYUSER}"

#Managing user
if [ -n "${DOCKUID}" ]; then
  MYUID="${DOCKUID}"
fi
/usr/sbin/adduser -S -D -H -G "${MYUSER}" -u "${MYUID}" "${MYUSER}"

if [ "$1" = 'sickrage' ]; then
    /bin/chown -R "${MYUSER}" /config /cache
    exec su-suexec "${MYUSER}" /usr/bin/python /opt/sickrage/SickBeard.py --datadir=/config/ --config=/config/config.ini "$@"
fi

exec "$@"
