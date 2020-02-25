import os
import sys

from oauthenticator.awscognito import AWSCognitoAuthenticator
from tornado.httpclient import HTTPRequest

from proxy_configuration import configure_proxy

notebook_dir = os.environ.get('DOCKER_NOTEBOOK_DIR')
network_name = 'jupyterhub-network'

c.Spawner.debug = False
c.Spawner.default_url = '/lab'
c.Spawner.environment = {
    'SPARKMAGIC_CONF_DIR': '/etc/jupyterhub/conf/sparkmagic/',
    'JUPYTER_ENABLE_LAB': 'yes'
}

c.JupyterHub.hub_ip = '0.0.0.0'
c.JupyterHub.port = 8000

c.JupyterHub.ssl_key = '/etc/jupyterhub/conf/key.pem'
c.JupyterHub.ssl_cert = '/etc/jupyterhub/conf/cert.pem'

c.JupyterHub.admin_access = True
c.Authenticator.admin_users = {
    'jovyan',
}

c.JupyterHub.services = [
    {
        'name': 'cull-idle',
        'admin': True,
        'command': [sys.executable, '/usr/local/share/jupyterhub/cull_idle_servers.py', '--timeout=3600'],
    }
]

# https://cognito-idp.eu-west-2.amazonaws.com/${user_pool_id}/.well-known/openid-configuration
c.JupyterHub.authenticator_class = 'oauthenticator.awscognito.AWSCognitoAuthenticator'
c.AWSCognitoAuthenticator.client_id = ''
c.AWSCognitoAuthenticator.client_secret = ''
c.AWSCognitoAuthenticator.oauth_callback_url = ''
c.AWSCognitoAuthenticator.username_key = 'username'
# c.AWSCognitoAuthenticator.oauth_logout_redirect_url = 'YOUR_LOGOUT_REDIRECT_URL'

"""HACK: consume HTTPS_PROXY and NO_PROXY environment variables so Hub can connect to external services.
https://github.com/jupyterhub/oauthenticator/issues/217"""
HTTPRequest._DEFAULTS['prepare_curl_callback'] = configure_proxy
