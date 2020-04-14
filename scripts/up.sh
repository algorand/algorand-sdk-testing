#!/usr/bin/env bash
set -e

rootdir=`dirname $0`
pushd $rootdir/..

# Make sure it isn't running
./scripts/down.sh

# Make sure the state is reset.
docker-compose rm --force

docker-compose build --no-cache
docker-compose up -d
