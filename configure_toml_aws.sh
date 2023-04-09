#!/bin/bash

export origin_region=$(aws configure get region)
aws configure set default.region eu-north-1
aws codeartifact login --tool pip --repository devocean-repo --domain devocean-domain --domain-owner 868523441767
export CODEARTIFACT_AUTH_TOKEN=`aws codeartifact get-authorization-token --domain devocean-domain --domain-owner 868523441767 --query authorizationToken --output text`
poetry config repositories.devocean-repo https://devocean-domain-868523441767.d.codeartifact.eu-north-1.amazonaws.com/pypi/devocean-repo/simple/
poetry config http-basic.devocean-repo aws $CODEARTIFACT_AUTH_TOKEN
aws configure set default.region $origin_region
export AWS_CODEARTIFACT_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_CODEARTIFACT_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
export AWS_CODEARTIFACT_SESSION_TOKEN=$(aws configure get aws_session_token)
export AWS_CODEARTIFACT_ACCOUNT="868523441767"
