#!/bin/bash

echo '>>>>>> Restarting node web server ...'

APP_LOCATION=~/app
PORT=${1}

lsof -i:${PORT} && APP_STARTED="started"
cd ${APP_LOCATION}

if [ "${APP_STARTED}" ]; then
  npx forever stop 0
  echo "[restart]: App stopped." | tee -a /tmp/terraform-provisioner.log
else
  echo "[restart]: App already stopped. Starting..." | tee -a /tmp/terraform-provisioner.log
fi

sleep 5
npx forever start server.js >> app.log 2>&1
echo "[restart]: App started." | tee -a /tmp/terraform-provisioner.log
