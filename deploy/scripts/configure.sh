#!/bin/bash

echo '>>>>>> Configuring node web server ...'

APP_LOCATION=~/app
cd ${APP_LOCATION}

test -f ".env" && APP_CONFIGURED="already"

if [ "$APP_CONFIGURED" ]; then
  echo "[configure] Application already configured." >> /tmp/terraform-provisioner.log
else
  echo "[configure] Building  the node app on ${1} using table ${5} in ${APP_LOCATION}." >> /tmp/terraform-provisioner.log
  npm install
  npm install -g forever

  echo "PORT=${1}" >> .env
  echo "REGION=${2}" >> .env
  echo "ACCESS_KEY=${3}" >> .env
  echo "SECRET_ACCESS_KEY=${4}" >> .env
  echo "TABLE_NAME=${5}" >> .env

  echo "[configure] Configuration done." >> /tmp/terraform-provisioner.log
fi

