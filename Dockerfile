FROM jupyterhub/jupyterhub:1.2
ADD requirements.txt /srv/jupyterhub/
RUN pip install \
    --trusted-host pypi.org \
    --trusted-host pypi.python.org \
    --trusted-host files.pythonhosted.org \
    -r /srv/jupyterhub/requirements.txt
ADD kernels /srv/jupyterhub/
# TODO conda install
# TODO enable r kernel
ENTRYPOINT ["jupyterhub"]
EXPOSE 8000
# TODO Add COMMAND to pickup config file
