#!/usr/bin/env bash

set -euo pipefail

START=$(date "+%s")

THIS=$(basename "$0")
ENV_FILE=".env"
echo "$THIS: sourcing environment vars from-->$(pwd)/$ENV_FILE"

set -a
source "$ENV_FILE"
set +a

if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  echo "$THIS: setting sandbox variables for git based on TYPE=$TYPE."
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

# Make sure test-sdk sandbox isn't running and clean up any docker detritous
echo "$THIS: before bootstrapping, try cleaning up first..."
./scripts/down.sh
rm -rf "$LOCAL_SANDBOX_DIR"
echo "$THIS: seconds it took to get to end of $LOCAL_SANDBOX_DIR cleanup: $(($(date "+%s") - START))s"


rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

git clone --depth 1 --branch "$SANDBOX_BRANCH" --single-branch "$SANDBOX_URL" "$LOCAL_SANDBOX_DIR"

cp .env "$LOCAL_SANDBOX_DIR"/.

SANDBOX_CFG="config.harness"
echo "$THIS: about to envsubst < $SANDBOX_CFG  > $LOCAL_SANDBOX_DIR/$SANDBOX_CFG"
envsubst < "$SANDBOX_CFG" > "$LOCAL_SANDBOX_DIR/$SANDBOX_CFG"

echo "$THIS: resulting $LOCAL_SANDBOX_DIR/$SANDBOX_CFG:"
cat "$LOCAL_SANDBOX_DIR/$SANDBOX_CFG"

echo ""
echo "$THIS: seconds it took to get to end of cloning sandbox into $LOCAL_SANDBOX_DIR: $(($(date "+%s") - START))s"
echo ""
echo "$THIS: bringing up network with TYPE=$TYPE configuration."

pushd "$LOCAL_SANDBOX_DIR"

[[ "$VERBOSE_HARNESS" = 1 ]] && V_FLAG="-v" || V_FLAG=""


./sandbox up "$V_FLAG" harness
echo "$THIS: seconds it took to finish getting harness ($LOCAL_SANDBOX_DIR) up and running: $(($(date "+%s") - START))s"
