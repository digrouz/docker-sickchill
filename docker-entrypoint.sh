#!/bin/sh
set -e
local MYUSER="sickrage"
local MYGID="10000"
local MYUID="10000"

#Managing group
if [ -n "${DOCKGID}" ]; then
  MYGID="${DOCKGID}"
fi
if ! /bin/grep -q "${MYUSER}" /etc/group; then
  /usr/sbin/addgroup -S -g "${MYGID}" "${MYUSER}"
fi

#Managing user
if [ -n "${DOCKUID}" ]; then
  MYUID="${DOCKUID}"
fi
if ! /bin/grep -q "${MYUSER}" /etc/passwd; then
  /usr/sbin/adduser -S -D -H -G "${MYUSER}" -u "${MYUID}" "${MYUSER}"
fi

if [ "$1" = 'sickrage' ]; then
    /bin/chown -R "${MYUSER}":"${MYUSER}" /config /opt/sickrage
    /bin/chmod -R g+w /config /opt/sickrage
    exec /sbin/su-exec "${MYUSER}" /usr/bin/python /opt/sickrage/SickBeard.py --nolaunch --datadir=/config/ --config=/config/config.ini "$@"
fi

exec "$@"
