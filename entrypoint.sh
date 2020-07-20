#!/usr/bin/env bash

## Script to generate SSL certificates and then start jupyterhub

/usr/bin/openssl req -x509 -newkey rsa:4096 -keyout /etc/jupyterhub/conf/key.pem -out /etc/jupyterhub/conf/cert.pem -days 30 -nodes -subj '/CN=jupyter'

echo "Adding ${USER}"
adduser -h "/home/${USER}" -D ${USER}
sed -i "s/USERNAME_TO_REPLACE/${USER}/g" /home/${USER}/.sparkmagic/config.json
sed -i "s/EMR_HOST_NAME_TO_REPLACE/${EMR_HOST_NAME}/g" /home/${USER}/.sparkmagic/config.json
sed -i "s/LIVY_SESSION_STARTUP_TIMEOUT_SECONDS_TO_REPLACE/${LIVY_SESSION_STARTUP_TIMEOUT_SECONDS:-120}/g" /home/${USER}/.sparkmagic/config.json

crontab -l > /tmp/crontab
echo "${PUSH_CRON:-* * * * 2099} curl -s https://localhost:8000/hub/metrics -k | curl -s --data-binary @- http://${PUSH_HOST:-localhost}:${PUSH_PORT:-9091}/metrics/job/jupyterhub/instance/${USER}" >> /tmp/crontab
crontab /tmp/crontab
rm /tmp/crontab

## Configure Spark-Monitor
jupyter nbextension install sparkmonitor --py --user --symlink
jupyter nbextension enable sparkmonitor --py --user
jupyter serverextension enable --py --user sparkmonitor
ipython profile create && echo "c.InteractiveShellApp.extensions.append('sparkmonitor.kernelextension')" >>  $(ipython profile locate default)/ipython_kernel_config.py

/usr/sbin/crond -f -l 8 &
jupyterhub $@
