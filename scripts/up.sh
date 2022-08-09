#!/usr/bin/env bash

# Bring up the SDK test environment.

set -e

START=$(date "+%s")

# Defaults
TYPE_OVERRIDE=""
ENV_FILE=".env"

# Load environment
echo "up.sh: sourcing environment vars from-->$ENV_FILE"
source "$ENV_FILE"

# Choose which dockerfile to use.
TYPE=${TYPE_OVERRIDE:-$TYPE}
if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  export TYPE="$TYPE"
else
  echo "up.sh: Unknown environment: $TYPE"
  exit 1
fi

echo "up.sh: Before bootrapping, try cleaning up first..."

# Make sure test-sdk sandbox isn't running and clean up any docker detritous
./scripts/down.sh -f "$ENV_FILE"
rm -rf "$SANDBOX_DIR"
echo "up.sh: seconds it took to get to end of $SANDBOX_DIR cleanup: " + $(($(date "+%s") - $START))

SANDBOX_CFG="_config.harness"
cp config.harness "$SANDBOX_CFG"
if [[ $TYPE == "channel" ]]; then
  ALGOD_URL=""
  ALGOD_BRANCH=""
  ALGOD_SHA=""
else
  ALGOD_CHANNEL=""
fi

if [[ $OSTYPE == 'darwin'* ]]; then
  SED_CMD='sed -i "" '
else
  SED_CMD='sed -i '
fi

echo "up.sh: On this OSTYPE=$OSTYPE using sed variant $SED_CMD"
echo "up.sh: apply regex replacements on SANDBOX_CFG=$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_CHANNEL|$ALGOD_CHANNEL|g" "$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_URL|$ALGOD_URL|g" "$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_BRANCH|$ALGOD_BRANCH|g" "$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_SHA|$ALGOD_SHA|g" "$SANDBOX_CFG"
$SED_CMD "s|#NETWORK_TEMPLATE|$NETWORK_TEMPLATE|g" "$SANDBOX_CFG"
$SED_CMD "s|#NETWORK_NUM_ROUNDS|$NETWORK_NUM_ROUNDS|g" "$SANDBOX_CFG"
$SED_CMD "s|#NODE_ARCHIVAL|$NODE_ARCHIVAL|g" "$SANDBOX_CFG"
$SED_CMD "s|#NODE_V1_INDEXER|$NODE_V1_INDEXER|g" "$SANDBOX_CFG"
$SED_CMD "s|#INDEXER_URL|$INDEXER_URL|g" "$SANDBOX_CFG"
$SED_CMD "s|#INDEXER_BRANCH|$INDEXER_BRANCH|g" "$SANDBOX_CFG"
$SED_CMD "s|#INDEXER_SHA|$INDEXER_SHA|g" "$SANDBOX_CFG"

echo "up.sh: resulting $SANDBOX_CFG:"
cat "$SANDBOX_CFG"

rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

git clone --branch "$SANDBOX_BRANCH" --single-branch "$SANDBOX_URL" "$SANDBOX_DIR"

echo "up.sh: seconds it took to get to end of cloning sandbox into $SANDBOX_DIR: " + $(($(date "+%s") - $START))
echo ""
echo "up.sh: bringing up network with '$TYPE' configuration."
cp .env "$SANDBOX_DIR"/.
mv "$SANDBOX_CFG" "$SANDBOX_DIR"/config.harness
pushd "$SANDBOX_DIR"

./sandbox up -v harness
echo "up.sh: seconds it took to finish with harness ($SANDBOX_DIR) up and running: " + $(($(date "+%s") - $START))
