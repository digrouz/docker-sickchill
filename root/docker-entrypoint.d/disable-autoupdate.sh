#!/usr/bin/env bash

sed -i \
  -e 's|auto_update =.*|auto_update = 0|g' \
/config/config.ini
