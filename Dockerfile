FROM public.ecr.aws/sam/build-python3.9 as intermediate

RUN mkdir /src
ADD pyproject.toml /src/pyproject.toml

ARG KEY_ID
ARG SECRET_KEY
ARG SESSION_TOKEN
ARG ACCOUNT
ARG PYPI_REPO_URL="https://pypi.python.org/simple"

WORKDIR /src

RUN aws configure set aws_access_key_id $KEY_ID && aws configure set aws_secret_access_key $SECRET_KEY && aws configure set default.region eu-north-1
RUN if [ -z "$SESSION_TOKEN" ] ; then echo "not session token" ; else aws configure set default.aws_session_token $SESSION_TOKEN ; fi

RUN curl -sSL https://install.python-poetry.org | python -
RUN aws codeartifact login --tool pip --repository devocean-repo --domain devocean-domain --domain-owner $ACCOUNT
RUN export CODEARTIFACT_AUTH_TOKEN=`aws codeartifact get-authorization-token --domain devocean-domain --domain-owner $ACCOUNT --query authorizationToken --output text` && $HOME/.local/bin/poetry config http-basic.devocean-repo aws $CODEARTIFACT_AUTH_TOKEN
RUN $HOME/.local/bin/poetry config repositories.devocean-repo https://devocean-domain-$ACCOUNT.d.codeartifact.eu-north-1.amazonaws.com/pypi/devocean-repo/simple/
RUN $HOME/.local/bin/poetry update --only main || exit 3
RUN pip install pytest --index-url $PYPI_REPO_URL
RUN pip install pytest-custom_exit_code --index-url $PYPI_REPO_URL
RUN pytest --suppress-no-test-exit-code -vvv