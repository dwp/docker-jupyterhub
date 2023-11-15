# DO NOT USE THIS REPO - MIGRATED TO GITLAB

# docker-jupyterhub

[![CircleCI](https://circleci.com/gh/dwp/docker-jupyterhub.svg?style=svg)](https://circleci.com/gh/dwp/docker-jupyterhub) [![Known Vulnerabilities](https://snyk.io/test/github/dwp/docker-jupyterhub/badge.svg)](https://snyk.io/test/github/dwp/docker-jupyterhub) [![DockerHub Pulls](https://img.shields.io/docker/pulls/dwpdigital/jupyterhub)](https://hub.docker.com/r/dwpdigital/jupyterhub)

A JupyterHub container with required extensions and libraries

## Environment Variables
This jupyterhub image requires the following environment variables at runtime:

| Env var | Description | Example value | Required |
| ------- | ----------- | ------------- | -------- |
| USER    | User to run jupyterhub as | steve | true |
| KMS_HOME    | ARN for users home KMS Key | arn:xxx: | true |
| KMS_SHARED    | ARN for shared KMS Key | arn:xxx: | true |
| LIVY_SESSION_STARTUP_TIMEOUT_SECONDS | Sparkmagic config to set the timeout for the Livy session startup | 120 | false |

The following environment variables can be used to configure Cognito authentication. 

| Env var | Description | Example value |
| ------- | ----------- | ------------- |
| COGNITO_ENABLED    | Enable Cognito Auth | true |
| COGNITO_CLIENT_ID  | Cognito Client ID | exampleid |
| COGNITO_CLIENT_SECRET | Cognito Client Secret | examplesecret |
| COGNITO_OAUTH_CALLBACK_URL | Callback url for successful login | `http://localhost:3000`|
| COGNITO_OAUTH_LOGOUT_CALLBACK_URL | Callback url for logout | `http://example.com`

If Cognito Authentication is enabled, home directories for the Cognito users need to be created manually
