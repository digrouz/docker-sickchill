#!/usr/bin/env bash

SICKCHILL_URL="https://api.github.com/repos/sickchill/sickchill/git/refs/tags"

FULL_LAST_VERSION=$(curl -SsL ${SICKCHILL_URL} | jq '.[-1].ref' -r | sed -e 's|refs/tags/||')
LAST_VERSION="${FULL_LAST_VERSION:1}"

sed -i -e "s|SICKCHILL_VERSION='.*'|SICKCHILL_VERSION='${LAST_VERSION}'|" Dockerfile*

if output=$(git status --porcelain) && [ -z "$output" ]; then
  # Working directory clean
  echo "No new version available!"
else 
  # Uncommitted changes
  git commit -a -m "update to version: ${LAST_VERSION}"
  git push
fi
