#!/usr/bin/env bash

set -e
 echo "IT works => root:${SSHPASS_ENV}"
 echo "root:${SSHPASS_ENV}" | chpasswd


exec "$@"

