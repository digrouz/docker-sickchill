#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

DockLog "Retrieving last commit id"
MYCOMMITID=$(curl -SsL "https://api.github.com/repos/SickChill/SickChill/tags"  | jq  ".[] | select(.name==\"v${SICKCHILL_VERSION}\") | .commit.sha" | tr -d \")

DockLog "Setting cur_commit_hash in /config/config.ini"
sed -i \
  -e "s|cur_commit_hash =.*|cur_commit_hash = ${MYCOMMITID}|g" \
/config/config.ini
