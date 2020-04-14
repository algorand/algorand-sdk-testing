#!/usr/bin/env bash

set -e

rootdir=`dirname $0`
pushd $rootdir

# Make sure the state is reset.
docker-compose rm --force

# Uses --force-recreate to ensure that nightly version is updated.
docker-compose up --build --force-recreate --no-deps -d
