#!/usr/bin/env bash
rootdir=`dirname $0`
pushd $rootdir/.. > /dev/null

docker-compose down
docker-compose rm --force

# In case a graceful shutdown fails, bring them down the hard way.
#docker kill $(docker ps -f name="sdk-harness")
docker ps -f name="sdk-harness" -q | xargs -r docker kill
