#!/bin/bash
PHASE=$1
case "$PHASE" in
    pre)

            echo "building lambda dependencies .."
            docker build . -t iac-scanner-lambda-deps --platform linux/amd64 --build-arg KEY_ID=$AWS_CODEARTIFACT_ACCESS_KEY_ID --build-arg SECRET_KEY=$AWS_CODEARTIFACT_SECRET_ACCESS_KEY --build-arg SESSION_TOKEN=$AWS_CODEARTIFACT_SESSION_TOKEN --build-arg ACCOUNT=$AWS_CODEARTIFACT_ACCOUNT || exit 1
            docker run  --platform linux/amd64 -v "$PWD":/src iac-scanner-lambda-deps /bin/bash /src/export_python_lib.sh || exit 1

            echo "unzipping dependencies files ..."
            unzip ./lib.zip > /dev/null
            rm ./lib.zip

            echo "creating 'build' directory ..."
            [[ -d ./build ]] && rm -r ./build
            mkdir ./build
            mv ./site-packages ./build/site-packages

            if test -f "cdk_hooks_pre.sh"; then
              echo "running cdk pre hooks ..."
              /bin/bash cdk_hooks_pre.sh
            fi
            ;;
    post)
            if test -f "cdk_hooks_post.sh"; then
              echo "running cdk post hooks ..."
              /bin/bash cdk_hooks_post.sh
            fi

            echo "deleting lib/build files ..."
            rm -rf ./build
            ;;
    *)
            echo "Please provide a valid cdk_hooks phase"
            exit 64
esac
