#!/usr/bin/env bash

set -euo pipefail

START=$(date "+%s")

THIS=$(basename "$0")
THIS="[algorand-testing-harness]$THIS"

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-algorand-testing-harness}"

ENV_FILE=".env"
echo "$THIS: sourcing environment vars from-->$(pwd)/$ENV_FILE"

set -a
source "$ENV_FILE"
set +a

# TODO: allow more than just --verbose env var overrides

# Verbose flag sets sandbox verbose flag and in turn docker compose verbose flag.
while (( "$#" )); do
  case "$1" in
    -v|--verbose)
      VERBOSE_HARNESS=1
      ;;
  esac
  shift
done
echo "$THIS: Harness/sandbox/docker compose verbosity=$VERBOSE_HARNESS"
echo "$THIS: Algod channel/source type TYPE=$TYPE"

if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  if [[ $TYPE == "channel" ]]; then
    ALGOD_URL=""
    ALGOD_BRANCH=""
    ALGOD_SHA=""
  else
    ALGOD_CHANNEL=""
  fi
else
  echo "Unknown environment: $TYPE"
  exit 1
fi

# Make sure test-sdk sandbox isn't running and clean up any docker detritous.  
# down.sh calls "sandbox down" followed by "sandbox clean"
echo "$THIS: before bootstrapping, try cleaning up first..."
./scripts/down.sh
rm -rf "$LOCAL_SANDBOX_DIR"
echo "$THIS: seconds execution time for $(pwd)/$LOCAL_SANDBOX_DIR cleanup: $(($(date "+%s") - START))s"


rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

echo "$THIS: Clone the sandbox repo branch $SANDBOX_BRANCH from $SANDBOX_URL into $LOCAL_SANDBOX_DIR"
git clone --depth 1 --branch "$SANDBOX_BRANCH" --single-branch "$SANDBOX_URL" "$LOCAL_SANDBOX_DIR"

cp "$ENV_FILE" "$LOCAL_SANDBOX_DIR"/.

SANDBOX_CFG="config.harness"
echo "$THIS: populating environment variables into $SANDBOX_CFG and storing in $LOCAL_SANDBOX_DIR/$SANDBOX_CFG (below)"
envsubst < "$SANDBOX_CFG" > "$LOCAL_SANDBOX_DIR/$SANDBOX_CFG"
cat "$LOCAL_SANDBOX_DIR/$SANDBOX_CFG"

echo "$THIS: seconds to execute sandbox cloning to $(pwd)/$LOCAL_SANDBOX_DIR: $(($(date "+%s") - START))s"
echo "$THIS: bringing up network with TYPE=$TYPE configuration."

pushd "$LOCAL_SANDBOX_DIR"

if [[ "$VERBOSE_HARNESS" = 1 ]]; then
echo "$THIS: running sandbox with command [./sandbox up -v harness ]"
./sandbox up -v harness 
else
echo "$THIS: running sandbox with command [./sandbox up harness ]"
./sandbox up harness 
fi
echo "$THIS: seconds to get sandbox harness ($(pwd)) up and running: $(($(date "+%s") - START))s"
