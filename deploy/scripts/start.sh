#!/bin/bash

echo '>>>>>> Starting node web server ...'
APP_LOCATION=~/app

PORT=${1}
lsof -i:${PORT} && APP_STARTED="already"

if [ "${APP_STARTED}" ]; then
  echo "[start]: App already started." | tee -a /tmp/terraform-provisioner.log
else
  touch ${APP_LOCATION}/app.log

  # Start the server
  cd ${APP_LOCATION}
  echo "Attempting to start app at ${APP_LOCATION} on port ${PORT}:"
  npx forever start server.js >> app.log 2>&1
  echo "[start]: 'serve.js' called writing to app.log." | tee -a /tmp/terraform-provisioner.log
  # for good measure, show the ps tree output
  ps -efj --forest | tee -a /tmp/terraform-provisioner.log

  echo "[start] Application started." >> /tmp/terraform-provisioner.log
fi

