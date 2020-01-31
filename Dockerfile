FROM jupyterhub/jupyterhub:1.2
RUN apt-get update \
    && apt-get install -y pandoc \
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
ENTRYPOINT ["jupyterhub"]
EXPOSE 8000
# TODO Add COMMAND to pickup config file
