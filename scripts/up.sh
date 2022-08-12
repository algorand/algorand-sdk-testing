#!/usr/bin/env bash

set -ae
START=$(date "+%s")


echo "up.sh: sourcing environment vars from-->$ENV_FILE"
ENV_FILE=".env"
source "$ENV_FILE"

if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  export TYPE="$TYPE"
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
echo "up.sh: Before bootstrapping, try cleaning up first..."
./scripts/down.sh
rm -rf "$SANDBOX_DIR"
echo "up.sh: seconds it took to get to end of $SANDBOX_DIR cleanup: " + $(($(date "+%s") - $START))


rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

git clone --branch "$SANDBOX_BRANCH" --single-branch "$SANDBOX_URL" "$SANDBOX_DIR"

cp .env "$SANDBOX_DIR"/.

SANDBOX_CFG="config.harness"
echo "up.sh: about to envsubst < $SANDBOX_CFG  > $SANDBOX_DIR/$SANDBOX_CFG"
envsubst < "$SANDBOX_CFG" > "$SANDBOX_DIR/$SANDBOX_CFG"

echo "up.sh: resulting $SANDBOX_DIR/$SANDBOX_CFG:"
cat "$SANDBOX_DIR/$SANDBOX_CFG"

echo ""
echo "up.sh: seconds it took to get to end of cloning sandbox into $SANDBOX_DIR: " + $(($(date "+%s") - $START))
echo ""
echo "up.sh: bringing up network with TYPE=$TYPE configuration."

pushd "$SANDBOX_DIR"

./sandbox up -v harness
echo "up.sh: seconds it took to finish with harness ($SANDBOX_DIR) up and running: " + $(($(date "+%s") - $START))
