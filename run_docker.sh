#!/usr/bin/env bash

rootdir=`dirname $0`
pushd $rootdir
docker build -t sdk-testing -f ./scripts/docker/Dockerfile $rootdir
docker run -v $(pwd):/opt/sdk-testing sdk-testing:latest /bin/bash -c "GO111MODULE=off && ./scripts/setup.sh && ./scripts/test.sh"
