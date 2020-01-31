#!/usr/bin/env bash

set -e

rootdir=`dirname $0`
pushd $rootdir
docker build -t sdk-testing -f ./scripts/docker/Dockerfile $rootdir

# Example running local java sdk code in the container
#docker run -it \
#      -v $(pwd):/opt/sdk-testing \
#      -v /home/will/algorand/java-algorand-sdk:/opt/mounted_java_sdk \
#      sdk-testing:latest \
#      /bin/bash -c "\
#            GO111MODULE=off && \
#            ./scripts/docker/setup.py --java-dir /opt/mounted_java_sdk && \
#            ./scripts/docker/test.sh --java"

#docker run -it -v $(pwd):/opt/sdk-testing sdk-testing:latest /bin/bash -c "GO111MODULE=off && ./scripts/docker/setup.py --algod-config scripts/config_future && ./scripts/test.sh"

docker run -it -v $(pwd):/opt/sdk-testing sdk-testing:latest
