#!/usr/bin/env bash
#
# Bring up the SDK test environment.

START=$(date "+%s")

# Defaults
TYPE_OVERRIDE=""
ENV_FILE=".env"

# Load environment
echo "up.sh is sourcing environment vars from-->$ENV_FILE"
source "$ENV_FILE"

# Choose which dockerfile to use.
TYPE=${TYPE_OVERRIDE:-$TYPE}
if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  export TYPE="$TYPE"
else
  echo "Unknown environment: $TYPE"
  exit 1
fi

echo "Before bootrapping, try cleaning up first..."

# Make sure it isn't running and clean up any docker detritous
./scripts/down.sh -f "$ENV_FILE"
rm -rf "$SANDBOX"
echo "up.sh. seconds it took to get to end of $SANDBOX cleanup: " + $(($(date "+%s") - $START))

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

echo "On this OSTYPE=$OSTYPE using sed variant $SED_CMD"

echo "apply regex replacements on SANDBOX_CFG=$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_CHANNEL|$ALGOD_CHANNEL|g" "$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_URL|$ALGOD_URL|g" "$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_BRANCH|$ALGOD_BRANCH|g" "$SANDBOX_CFG"
$SED_CMD "s|#ALGOD_SHA|$ALGOD_SHA|g" "$SANDBOX_CFG"
$SED_CMD "s|#NETWORK_TEMPLATE|$NETWORK_TEMPLATE|g" "$SANDBOX_CFG"
$SED_CMD "s|#NETWORK_NUM_ROUNDS|$NETWORK_NUM_ROUNDS|g" "$SANDBOX_CFG"
$SED_CMD "s|#INDEXER_URL|$INDEXER_URL|g" "$SANDBOX_CFG"
$SED_CMD "s|#INDEXER_BRANCH|$INDEXER_BRANCH|g" "$SANDBOX_CFG"
$SED_CMD "s|#INDEXER_SHA|$INDEXER_SHA|g" "$SANDBOX_CFG"

echo "Resulting $SANDBOX_CFG:"
cat "$SANDBOX_CFG"

rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

SANDBOX_BRANCH="configurable-ports"
git clone --branch $SANDBOX_BRANCH --single-branch https://github.com/algorand/sandbox.git $SANDBOX

echo "up.sh. seconds it took to get to end of cloning sandbox into $SANDBOX: " + $(($(date "+%s") - $START))

echo "Bringing up network with '$TYPE' configuration."
cp .env "$SANDBOX"/.
mv "$SANDBOX_CFG" "$SANDBOX"/config.harness
pushd "$SANDBOX"

./sandbox up harness
echo "up.sh. seconds it took to finish with harness ($SANDBOX) up and running: " + $(($(date "+%s") - $START))
