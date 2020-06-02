#!/usr/bin/env bash

## Script to generate SSL certificates and then start jupyterhub

/usr/bin/openssl req -x509 -newkey rsa:4096 -keyout /etc/jupyterhub/conf/key.pem -out /etc/jupyterhub/conf/cert.pem -days 30 -nodes -subj '/CN=jupyter'

echo "Adding ${USER}"
adduser -h "/home/${USER}" -D ${USER}
sed -i "s/USERNAME_TO_REPLACE/${USER}/g" /home/${USER}/.sparkmagic/config.json
sed -i "s/EMR_HOST_NAME_TO_REPLACE/${EMR_HOST_NAME}/g" /home/${USER}/.sparkmagic/config.json
sed -i "s/LIVY_SESSION_STARTUP_TIMEOUT_SECONDS_TO_REPLACE/${LIVY_SESSION_STARTUP_TIMEOUT_SECONDS:-120}/g" /home/${USER}/.sparkmagic/config.json

jupyterhub $@
