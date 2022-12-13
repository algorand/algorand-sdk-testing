#!/usr/bin/env bash
THIS=$(basename "$0")

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-algorand-testing-harness}"
ENV_FILE=".env"

# Load environment.
echo "$THIS: sourcing environment vars from-->$(pwd)/$ENV_FILE"
source "$ENV_FILE"
echo "$THIS: looking to clean up inside-->$(pwd)/$LOCAL_SANDBOX_DIR"

if [ -d "$LOCAL_SANDBOX_DIR" ]; then
  pushd "$LOCAL_SANDBOX_DIR"
  ./sandbox down
  ./sandbox clean
else
  echo "$THIS: directory $(pwd)/$LOCAL_SANDBOX_DIR does not exist - NOOP"
fi
