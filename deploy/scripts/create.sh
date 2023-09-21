#!/bin/bash

echo '>>>>>> Installing nodejs & npm ...'

# function to install node
install_node () {
   echo "[create] Installing node & npm." >> /tmp/terraform-provisioner.log
    # Download and import the Nodesource GPG key
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    # Create deb repository
    NODE_MAJOR=20
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    # Run Update and Install
    sudo apt-get update
    sudo apt-get install nodejs -y
    echo "[create] node & npm installed." >> /tmp/terraform-provisioner.log
}

which node || \
    { install_node ; } || \
    { echo ">>>>>> WARNING: cannot install node" && exit 1 ; }

APP_LOCATION=~/app
test -d "${APP_LOCATION}" && APP_EXISTS="already"

if [ "${APP_EXISTS}" ]; then
  echo "[create]: App already installed." | tee -a /tmp/terraform-provisioner.log
else
  cd ~/
  mkdir -p app
  mv /tmp/server.js ${APP_LOCATION}/
  mv /tmp/package.json ${APP_LOCATION}/
  test -d "${APP_LOCATION}" && APP_EXISTS="installed."
  echo "[create]: App installed?  ${FRONTEND_EXISTS}" | tee -a /tmp/terraform-provisioner.log
fi
