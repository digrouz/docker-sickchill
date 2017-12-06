#!/usr/bin/env bash

MYUSER="sickrage"
MYGID="10000"
MYUID="10000"
OS=""
MYUPGRADE="0"

DectectOS(){
  if [ -e /etc/alpine-release ]; then
    OS="alpine"
  elif [ -e /etc/os-release ]; then
    if grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then
      OS="ubuntu"
    fi
    if grep -q "NAME=\"CentOS Linux\"" /etc/os-release ; then
      OS="centos"
    fi
  fi
}

AutoUpgrade(){
  if [ -n "${DOCKUPGRADE}" ]; then
    MYUPGRADE="${DOCKUPGRADE}"
  fi
  if [ "${MYUPGRADE}" == 1 ]; then
    if [ "${OS}" == "alpine" ]; then
      apk --no-cache upgrade
      rm -rf /var/cache/apk/*
    elif [ "${OS}" == "ubuntu" ]; then
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get -y --no-install-recommends dist-upgrade
      apt-get -y autoclean
      apt-get -y clean
      apt-get -y autoremove
      rm -rf /var/lib/apt/lists/*
    elif [ "${OS}" == "centos" ]; then
      yum upgrade -y
      yum clean all
      rm -rf /var/cache/yum/*
    fi
  fi
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

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
  if grep -q "${MYUSER}" /etc/passwd; then
    OLDUID=$(id -u "${MYUSER}")
  fi
  if grep -q "${MYUSER}" /etc/group; then
      OLDGID=$(id -g "${MYUSER}")
  fi
  if [ "${MYUID}" != "${OLDUID}" ]; then
    OLDHOME=$(grep "$MYUSER" /etc/passwd | awk -F: '{print $6}')
    if [ "${OS}" == "alpine" ]; then
      deluser "${MYUSER}"
    else
      userdel "${MYUSER}"
    fi
    DockLog "Deleted user ${MYUSER}"
  fi
  if grep -q "${MYUSER}" /etc/group; then
    if [ "${MYGID}" != "${OLDGID}" ]; then
      if [ "${OS}" == "alpine" ]; then
        delgroup "${MYUSER}"
      else
        groupdel "${MYUSER}"
      fi
      DockLog "Deleted group ${MYUSER}"
    fi
  fi
  if ! grep -q "${MYUSER}" /etc/group; then
    if [ "${OS}" == "alpine" ]; then
      addgroup -S -g "${MYGID}" "${MYUSER}"
    else
      groupadd -r -g "${MYGID}" "${MYUSER}"
    fi
    DockLog "Created group ${MYUSER}"
  fi
  if ! grep -q "${MYUSER}" /etc/passwd; then
    if [ -z "${OLDHOME}" ]; then
      OLDHOME="/home/${MYUSER}"
      mkdir "${OLDHOME}"
      DockLog "Created home directory ${OLDHOME}"
    fi
    if [ "${OS}" == "alpine" ]; then
      adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
    else
      useradd --system --shell /sbin/nologin --gid "${MYGID}" --home-dir "${OLDHOME}" --uid "${MYUID}" "${MYUSER}"
    fi
    DockLog "Created user ${MYUSER}"

  fi
  if [ -n "${OLDUID}" ] && [ "${DOCKUID}" != "${OLDUID}" ]; then
    DockLog "Fixing permissions for user ${MYUSER}"
    find / -user "${OLDUID}" -exec chown ${MYUSER} {} \; &> /dev/null
    if [ "${OLDHOME}" == "/home/${MYUSER}" ]; then
      chown -R "${MYUSER}" "${OLDHOME}"
      chmod -R u+rwx "${OLDHOME}"
    fi
    DockLog "... done!"
  fi
  if [ -n "${OLDGID}" ] && [ "${DOCKGID}" != "${OLDGID}" ]; then
    DockLog "Fixing permissions for group ${MYUSER}"
    find / -group "${OLDGID}" -exec chgrp ${MYUSER} {} \; &> /dev/null
    if [ "${OLDHOME}" == "/home/${MYUSER}" ]; then
      chown -R :"${MYUSER}" "${OLDHOME}"
      chmod -R ga-rwx "${OLDHOME}"
    fi
    DockLog "... done!"
  fi
}

DockLog(){
  if [ "${OS}" == "centos" ] || [ "${OS}" == "alpine" ]; then
    echo "${1}"
  else
    logger "${1}"
  fi
}

DectectOS
AutoUpgrade
ConfigureUser

if [ "$1" == 'sickrage' ]; then
  DockLog "Fixing permissions on /config /opt/sickrage"
  chown -R "${MYUSER}":"${MYUSER}" /config /opt/sickrage
  chmod -R g+w /config /opt/sickrage
  DockLog "Starting app: ${1}"
  exec su-exec "${MYUSER}" python /opt/sickrage/SickBeard.py --nolaunch --datadir=/config/ --config=/config/config.ini
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi

