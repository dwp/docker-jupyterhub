FROM jupyterhub/jupyterhub:1.2

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        gcc \
        libkrb5-dev \
        pandoc \
        python3-dev \
    && apt-get clean

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1 \
    && update-alternatives --install /usr/local/bin/pip pip /usr/local/bin/pip3 1

RUN pip install --upgrade \
        pip \
        setuptools \
        wheel

ADD requirements.txt /srv/jupyterhub/
RUN pip install \
        --trusted-host pypi.org \
        --trusted-host pypi.python.org \
        --trusted-host files.pythonhosted.org \
        -r /srv/jupyterhub/requirements.txt

RUN apt-get remove -y --purge gcc \
        libkrb5-dev \
        pandoc \
        python3-dev \
    && apt-get autoremove -y

ADD https://raw.githubusercontent.com/jupyterhub/jupyterhub/master/examples/cull-idle/cull_idle_servers.py /usr/local/share/jupyterhub/

RUN jupyter lab build
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager

WORKDIR /usr/local/lib/python3.6/dist-packages
RUN jupyter-kernelspec install sparkmagic/kernels/pysparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/sparkrkernel
RUN jupyter serverextension enable --py sparkmagic

WORKDIR /etc/jupyterhub/conf
ADD proxy_configuration.py /usr/lib/python3/dist-packages/proxy_configuration.py
ADD example_jupyterhub_config.py /etc/jupyterhub/conf/jupyterhub_config.py
ADD example_config.json /etc/jupyterhub/conf/sparkmagic/config.json

ENTRYPOINT ["jupyterhub"]
CMD ["-f", "/etc/jupyterhub/conf/jupyterhub_config.py"]

EXPOSE 8000
