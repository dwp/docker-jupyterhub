#!/usr/bin/env bash

## Script to generate SSL certificates and then start jupyterhub

/usr/bin/openssl req -x509 -newkey rsa:4096 -keyout /etc/jupyterhub/conf/key.pem -out /etc/jupyterhub/conf/cert.pem -days 3650 -nodes -subj '/CN=jupyter'

echo "Adding ${USER}"
adduser -h "/home/${USER}" -D ${USER}
mkdir -p /home/${USER}/.sparkmagic
cp /etc/jupyterhub/conf/sparkmagic/template_sparkmagic_config.json /home/${USER}/.sparkmagic/template_sparkmagic_config.json
sed -i "s/USERNAME_TO_REPLACE/${USER}/g" /home/${USER}/.sparkmagic/template_sparkmagic_config.json
chown -R ${USER}:${USER} /home/${USER}
chmod -R 2770 /home/${USER}

jupyterhub $@
