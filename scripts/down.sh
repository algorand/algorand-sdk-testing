#!/usr/bin/env bash
set -e

rootdir=`dirname $0`
pushd $rootdir/..

docker-compose down
docker-compose rm --force
