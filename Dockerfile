FROM jupyterhub/jupyterhub:1.2
RUN apt-get update \
    && apt-get install -y \
            gcc \
            libkrb5-dev \
            pandoc \
            python3-dev \
    && apt-get clean
RUN pip3 install --upgrade \
        pip \
        setuptools \
        wheel
ADD requirements.txt /srv/jupyterhub/
RUN pip3 install \
        --trusted-host pypi.org \
        --trusted-host pypi.python.org \
        --trusted-host files.pythonhosted.org \
        -r /srv/jupyterhub/requirements.txt
ADD kernels /srv/jupyterhub/
# TODO conda install
# TODO enable r kernel
RUN jupyter lab build
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager

WORKDIR /usr/local/lib/python3.6/dist-packages
RUN jupyter-kernelspec install sparkmagic/kernels/sparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/pysparkkernel \
    && jupyter-kernelspec install sparkmagic/kernels/sparkrkernel

RUN jupyter serverextension enable --py sparkmagic

ADD example_config.json /etc/jupyterhub/conf/sparkmagic/config.json

ENTRYPOINT ["jupyterhub"]
EXPOSE 8000
# TODO Add COMMAND to pickup config file
