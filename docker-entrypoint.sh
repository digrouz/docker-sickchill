#!/bin/sh
set -e
local MYUSER="sickrage"
local MYGID="10000"
local MYUID="10000"

ConfigureUser () {
  # Managing user
  if [ -n "${DOCKUID}" ]; then
    MYUID="${DOCKUID}"
  fi
  # Managing group
  if [ -n "${DOCKGID}" ]; then
    MYGID="${DOCKGID}"
  fi
  local OLDHOME
  local OLDGID
  local OLDUID
  local USEREXISTS=$(/bin/grep -q "${MYUSER}" /etc/passwd)
  if [ $USEREXISTS -eq 0 ]; then
    OLDUID=$(/usr/bin/id -u "${MYUSER}")
    OLDGID=$(/usr/bin/id -g "${MYUSER}")
    if [ "${DOCKUID}" != "${OLDUID}" ]; then
      OLDHOME=$(/bin/echo "~${MYUSER}")
      /usr/sbin/deluser "${MYUSER}"
      /usr/bin/logger "Deleted user ${MYUSER}"
    fi
    local GROUPEXISTS=$(/bin/grep -q "${MYUSER}" /etc/group)
    if [ $GROUPEXISTS -eq 0 ]; then
      local OLDGID=$(/usr/bin/id -g "${MYUSER}")
      if [ "${DOCKGID}" != "${OLDGID}" ]; then
        /usr/sbin/delgroup "${MYUSER}"
        /usr/bin/logger "Deleted group ${MYUSER}"
      fi
    fi
  fi
  /usr/sbin/addgroup -S -g "${MYGID}" "${MYUSER}"
  /usr/sbin/adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
  if [ -n "${OLDUID}" ] && [ "${DOCKUID}" != "${OLDUID}" ]; then
    /usr/bin/find / -user "${OLDUID}" -exec /bin/chown ${MYUSER} {} \;
  fi
  if [ -n "${OLDGID}" ] && [ "${DOCKGID}" != "${OLDGID}" ]; then
    /usr/bin/find / -group "${OLDGID}" -exec /bin/chgrp ${MYUSER} {} \;
  fi
}

ConfigureUser

if [ "$1" = 'sickrage' ]; then
    /bin/chown -R "${MYUSER}":"${MYUSER}" /config /opt/sickrage
    /bin/chmod -R g+w /config /opt/sickrage
    exec /sbin/su-exec "${MYUSER}" /usr/bin/python /opt/sickrage/SickBeard.py --nolaunch --datadir=/config/ --config=/config/config.ini "$@"
fi

exec "$@"
