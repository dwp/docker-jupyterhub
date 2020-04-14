FROM alpine:latest

RUN apk add --no-cache alpine-sdk bash curl-dev g++ gcc krb5-dev krb5-libs libffi-dev nodejs npm openssl pkgconfig python3 python3-dev

RUN npm install -g configurable-http-proxy

RUN pip3 install --upgrade pip setuptools wheel pycurl

ADD requirements.txt /srv/jupyterhub/
RUN pip3 install \
    --trusted-host pypi.org \
    --trusted-host pypi.python.org \
    --trusted-host files.pythonhosted.org \
    -r /srv/jupyterhub/requirements.txt

ADD https://raw.githubusercontent.com/jupyterhub/jupyterhub/master/examples/cull-idle/cull_idle_servers.py /usr/local/share/jupyterhub/

RUN jupyter lab build \
    && jupyter nbextension enable --py --sys-prefix widgetsnbextension \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager

WORKDIR /usr/lib/python3.8/site-packages/

RUN jupyter-kernelspec install sparkmagic/kernels/pysparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/sparkrkernel \
    && jupyter serverextension enable --py sparkmagic

ADD proxy_configuration.py /usr/lib/python3.8/site-packages/proxy_configuration.py
ADD jupyterhub_config.py /etc/jupyterhub/conf/jupyterhub_config.py

# Create template user home
RUN mkdir -p /etc/skel/.sparkmagic
ADD template_sparkmagic_config.json /etc/skel/.sparkmagic/config.json

RUN apk del alpine-sdk g++ gcc krb5-dev libffi-dev npm pkgconfig python3-dev

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-f", "/etc/jupyterhub/conf/jupyterhub_config.py"]
