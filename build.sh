#!/usr/bin/env bash

set -e

rootdir=`dirname $0`
pushd $rootdir

#time docker build -t sdk-testing-indexer -f docker/indexer/Dockerfile "$(pwd)"
#docker run -it \
#  -p 59999:8980 \
#  sdk-testing-indexer

#time docker build -t sdk-testing -f docker/main/Dockerfile "$(pwd)"
#docker run -it  \
#  -p 60001:60001 \
#  -p 60000:60000 \
#  sdk-testing:latest

docker-compose rm --force && docker-compose up --build
