#!/usr/bin/env bash

ENV_FILE=".env"

# Load environment.
echo "down.sh: sourcing environment vars from-->$ENV_FILE"
source "$ENV_FILE"
echo "down.sh: looking to clean up inside-->$LOCAL_SANDBOX_DIR"

if [ -d "$LOCAL_SANDBOX_DIR" ]; then
  pushd "$LOCAL_SANDBOX_DIR"
  ./sandbox down
  ./sandbox clean
else
  echo "down.sh: directory $LOCAL_SANDBOX_DIR does not exist - NOOP"
fi
