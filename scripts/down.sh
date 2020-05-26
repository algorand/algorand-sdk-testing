#!/usr/bin/env bash
rootdir=`dirname $0`
pushd $rootdir/.. > /dev/null

docker-compose down
docker-compose rm --force

# In case a graceful shutdown/remove fails, bring them down the hard way.
#docker kill $(docker ps -f name="sdk-harness")
containers=$(docker ps -a -f name="sdk-harness" -q)
if [ ! -z "$containers" ]; then
  docker kill $containers
  docker rm $containers
fi
