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

mkdir /git
chmod 755 /git

git clone "codecommit::eu-west-2://${GIT_REPO}" /git/${GIT_REPO}

chown -R "${USER}:${USER}" /git

# Tells git branch, git switch and git checkout to set up new branches so that git-pull will
# appropriately merge from the starting point branch.
git config --global branch.autoSetupMerge always

# When pushing, don't ask for upstream branch - just push to the remote branch with the same name.
# Creates remote branch if it doesn't exist
git config --global push.default current

/usr/sbin/crond -f -l 8 &
jupyterhub $@
