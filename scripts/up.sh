#!/usr/bin/env bash
#
# Bring up the SDK test environment.

set -e

START=$(date "+%s")

# Defaults
TYPE_OVERRIDE=""
ENV_FILE=".env"

# Load environment
echo "up.sh is sourcing environment vars from-->$ENV_FILE"
source "$ENV_FILE"

# Verify there are no positional parameters with getopt/getopts
shift "$((OPTIND-1))"
if [[ "$1" != "" ]]; then
  echo "No positional arguments should be provided, found '$@'"
  echo
  show_help
  exit
fi

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

sed -i "" "s|#ALGOD_CHANNEL|$ALGOD_CHANNEL|g" "$SANDBOX_CFG"
sed -i "" "s|#ALGOD_URL|$ALGOD_URL|g" "$SANDBOX_CFG"
sed -i "" "s|#ALGOD_BRANCH|$ALGOD_BRANCH|g" "$SANDBOX_CFG"
sed -i "" "s|#ALGOD_SHA|$ALGOD_SHA|g" "$SANDBOX_CFG"
sed -i "" "s|#NETWORK_TEMPLATE|$NETWORK_TEMPLATE|g" "$SANDBOX_CFG"
sed -i "" "s|#NETWORK_NUM_ROUNDS|$NETWORK_NUM_ROUNDS|g" "$SANDBOX_CFG"
sed -i "" "s|#INDEXER_URL|$INDEXER_URL|g" "$SANDBOX_CFG"
sed -i "" "s|#INDEXER_BRANCH|$INDEXER_BRANCH|g" "$SANDBOX_CFG"
sed -i "" "s|#INDEXER_SHA|$INDEXER_SHA|g" "$SANDBOX_CFG"

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
