import os
import sys

from hybridcontents import HybridContentsManager
from HookEnabledS3ContentsManager import (
    HookEnabledS3ContentsManager as S3ContentsManager,
)
import getpass

username = getpass.getuser()

c = get_config()

c.NotebookApp.terminals_enabled = False

c.NotebookApp.contents_manager_class = HybridContentsManager

c.HybridContentsManager.manager_classes = {
    "s3home": S3ContentsManager,
    "s3shared": S3ContentsManager,
}

c.HybridContentsManager.manager_kwargs = {
    "s3home": {
        "bucket": os.environ.get("S3_BUCKET"),
        "prefix": "home/" + os.path.join(username, "jupyter_notebooks"),
        "sse": "aws:kms",
        "kms_key_id": os.environ.get("KMS_HOME"),
        "endpoint_url": "https://s3.eu-west-2.amazonaws.com",
    },
    "s3shared": {
        "bucket": os.environ.get("S3_BUCKET"),
        "prefix": "shared/jupyter_notebooks",
        "sse": "aws:kms",
        "kms_key_id": os.environ.get("KMS_SHARED"),
        "endpoint_url": "https://s3.eu-west-2.amazonaws.com",
    },
}


def no_spaces(path):
    return " " not in path


c.HybridContentsManager.path_validators = {}


def scrub_output_pre_save(path, model, contents_manager):
    """scrub output before saving notebooks"""
    # only run on notebooks
    if model["type"] != "notebook":
        return

    for cell in model["content"]["cells"]:
        if cell["cell_type"] != "code":
            continue
        cell["outputs"] = []
        cell["execution_count"] = None


c.S3ContentsManager.pre_save_hook = scrub_output_pre_save
