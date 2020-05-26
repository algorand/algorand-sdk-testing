#!/usr/bin/env bash

# This script is useful for development to quickly restart the
# environment for another round of tests.

# This should run only after up.sh and before down.sh

# Use this script for the following situation(s):

# Some tests alter the state of the blockchain, and running the again
# requires the initial blockchain state.
# For example: when the test rekeys an account, running the test again
# will fail to rekey using the initial key.
# Running this script between test runs will reset the blockchain state.

docker-compose down
docker-compose rm --force
docker-compose up -d


