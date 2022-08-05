#!/usr/bin/env bash

ENV_FILE=".up-env"

# Parse arguments
while getopts "f" opt; do
  case "$opt" in
    f) ENV_FILE=$OPTARG; ;;
    *) exit 1 ;;
  esac
done

# Load environment.
source "$ENV_FILE"

rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit
pushd "$SANDBOX"

./sandbox down
./sandbox clean
