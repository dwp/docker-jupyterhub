FROM dwpdigital/jupyterhub_base:latest

ADD proxy_configuration.py /usr/lib/python3.8/site-packages/proxy_configuration.py
ADD jupyterhub_config.py /etc/jupyterhub/conf/jupyterhub_config.py

# Add message logging
ADD handlers.py /usr/lib/python3.8/site-packages/notebook/services/kernels/handlers.py

# Create template user home
RUN mkdir -p /etc/skel/.sparkmagic /etc/skel/.jupyter/
ADD jupyter_local_conf.py /etc/skel/.jupyter/jupyter_notebook_config.py
ADD template_sparkmagic_config.json /etc/skel/.sparkmagic/config.json

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8000

HEALTHCHECK --interval=12s --timeout=12s --start-period=20s \  
 CMD wget -O- -S --no-check-certificate -q https://localhost:8000/hub/health
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-f", "/etc/jupyterhub/conf/jupyterhub_config.py"]
