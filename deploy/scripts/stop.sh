#!/bin/bash

echo '>>>>>> Stopping node web server ...'
APP_LOCATION=~/app
PORT=${1}

lsof -i:${PORT} && APP_STARTED="started"

if [ "${APP_STARTED}" ]; then
  npx forever stop 0
  echo "[stop]: App stopped." | tee -a /tmp/terraform-provisioner.log
else
  echo "[stop]: App already stopped. Nothing to do." | tee -a /tmp/terraform-provisioner.log
fi