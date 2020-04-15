#!/usr/bin/env bash
set -e

rootdir=`dirname $0`
pushd $rootdir/..

./scripts/down.sh
docker-compose rm --force

docker-compose up
