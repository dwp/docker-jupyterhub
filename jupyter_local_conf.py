import os
import sys

from hybridcontents import HybridContentsManager
from s3contents import S3ContentsManager
import getpass

username = getpass.getuser()

c = get_config()

c.NotebookApp.contents_manager_class = HybridContentsManager

c.HybridContentsManager.manager_classes = {
    's3home': S3ContentsManager,
    's3shared': S3ContentsManager
}

c.HybridContentsManager.manager_kwargs = {
    's3home': {
        "bucket": os.environ.get('S3_BUCKET'),
        "prefix": "home/" + os.path.join(username, "jupyter_notebooks")
    },
    's3shared': {
        "bucket": os.environ.get('S3_BUCKET'),
        "prefix": "shared/jupyter_notebooks"
    },
}

def no_spaces(path):
    return ' ' not in path

c.HybridContentsManager.path_validators = {
    's3home': no_spaces,
    's3shared': no_spaces
}