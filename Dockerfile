FROM alpine:latest

RUN apk add --no-cache alpine-sdk bash curl-dev curl g++ gcc krb5-dev krb5-libs libffi-dev nodejs npm openssl pkgconfig python3 python3-dev linux-pam git

RUN npm install -g configurable-http-proxy

RUN python3 -m ensurepip && \
    pip3 install --upgrade pip setuptools wheel pycurl

ADD requirements.txt /srv/jupyterhub/
RUN pip3 install -r /srv/jupyterhub/requirements.txt

RUN jupyter lab build --minimize=False \
    && jupyter nbextension enable --py --sys-prefix widgetsnbextension \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager@2.0

WORKDIR /usr/lib/python3.8/site-packages/

RUN jupyter-kernelspec install sparkmagic/kernels/pysparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/sparkrkernel \
    && jupyter serverextension enable --py sparkmagic

ADD proxy_configuration.py /usr/lib/python3.8/site-packages/proxy_configuration.py
ADD jupyterhub_config.py /etc/jupyterhub/conf/jupyterhub_config.py

# Add message logging
ADD handlers.py /usr/lib/python3.8/site-packages/notebook/services/kernels/handlers.py

# Create template user home
RUN mkdir -p /etc/skel/.sparkmagic /etc/skel/.jupyter/
ADD jupyter_local_conf.py /etc/skel/.jupyter/jupyter_notebook_config.py
ADD template_sparkmagic_config.json /etc/skel/.sparkmagic/config.json

RUN apk del alpine-sdk g++ gcc krb5-dev libffi-dev npm pkgconfig python3-dev

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8000

HEALTHCHECK --interval=12s --timeout=12s --start-period=20s \  
 CMD wget -O- -S --no-check-certificate -q https://localhost:8000/hub/health
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-f", "/etc/jupyterhub/conf/jupyterhub_config.py"]
