#!/usr/bin/env bash

# This script is useful for development to quickly restart the
# environment for another round of tests.
set -e

rootdir=`dirname $0`
pushd $rootdir/..

# Make sure it isn't running
./scripts/down.sh

# Make sure the state is reset.
docker-compose rm --force
docker-compose up -d
