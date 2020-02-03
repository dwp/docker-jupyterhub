import os
import logging
import sys

import pycurl
from fnmatch import fnmatch
from urllib.parse import urlparse
from tornado.httpclient import HTTPRequest

from oauthenticator.awscognito import AWSCognitoAuthenticator

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

c.JupyterHub.admin_access = True
c.Authenticator.admin_users = {
    'jovyan',
}

c.JupyterHub.services = [
    {
        'name': 'cull-idle',
        'admin': True,
        'command': [sys.executable, 'cull_idle_servers.py', '--timeout=3600'],
    }
]

# https://cognito-idp.eu-west-2.amazonaws.com/${user_pool_id}/.well-known/openid-configuration
c.JupyterHub.authenticator_class = 'oauthenticator.awscognito.AWSCognitoAuthenticator'
c.AWSCognitoAuthenticator.client_id = ''
c.AWSCognitoAuthenticator.client_secret = ''
c.AWSCognitoAuthenticator.oauth_callback_url = ''
c.AWSCognitoAuthenticator.username_key = 'username'
# c.AWSCognitoAuthenticator.oauth_logout_redirect_url = 'YOUR_LOGOUT_REDIRECT_URL'

# TODO move all the below to different file and import
# HACK: consume HTTP?_PROXY and NO_PROXY environment variables
# so Hub can connect to external Gitlab.
# https://github.com/jupyterhub/oauthenticator/issues/217


def get_proxies_for_url(url):
    http_proxy = os.environ.get("HTTP_PROXY", os.environ.get("http_proxy"))
    https_proxy = os.environ.get("HTTPS_PROXY", os.environ.get("https_proxy"))
    no_proxy = os.environ.get("NO_PROXY", os.environ.get("no_proxy"))
    p = urlparse(url)
    netloc = p.netloc
    _userpass, _, hostport = p.netloc.rpartition("@")
    url_hostname, _, _port = hostport.partition(":")
    proxies = {}
    if http_proxy:
        proxies["http"] = http_proxy
    if https_proxy:
        proxies["https"] = https_proxy
    if no_proxy:
        for hostname in no_proxy.split(","):
            # Support "*.server.com" and "10.*"
            if fnmatch(url_hostname, hostname.strip()):
                proxies = {}
                break
            # Support ".server.com"
            elif hostname.strip().replace("*", "").endswith(url_hostname):
                proxies = {}
                break
    return proxies


def configure_proxy(curl):
    logging.error("URL: {0}".format(curl.getinfo(pycurl.EFFECTIVE_URL)))
    # we only want google oauth to use the proxy
    proxies = get_proxies_for_url(curl.getinfo(pycurl.EFFECTIVE_URL))
    if proxies:
        host, _, port = proxies["https"].rpartition(":")
        logging.error("adding proxy: https={0}:{1}".format(host, port))
        curl.setopt(pycurl.PROXY, host)
        if port:
            curl.setopt(pycurl.PROXYPORT, int(port))


# never do this
HTTPRequest._DEFAULTS['prepare_curl_callback'] = configure_proxy
