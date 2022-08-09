#!/usr/bin/env bash

ENV_FILE=".env"

# Load environment.
echo "down.sh: sourcing environment vars from-->$ENV_FILE"
source "$ENV_FILE"
echo "down.sh: looking to clean up inside-->$SANDBOX_DIR"

if [ -d "$SANDBOX_DIR" ]; then
  pushd "$SANDBOX_DIR"
  ./sandbox down
  ./sandbox clean
else
  echo "down.sh: directory $SANDBOX_DIR does not exist - NOOP"
fi
