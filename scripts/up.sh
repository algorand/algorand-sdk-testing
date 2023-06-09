#!/usr/bin/env bash

set -euo pipefail

START=$(date "+%s")

THIS=$(basename "$0")
ENV_FILE=".env"
echo "$THIS: sourcing environment vars from-->$(pwd)/$ENV_FILE"

set -a
source "$ENV_FILE"
set +a

# TODO: allow more than just --verbose env var overrides
while (( "$#" )); do
  case "$1" in
    -v|--verbose)
      VERBOSE_HARNESS=1
      ;;
  esac
  shift
done
echo "$THIS: VERBOSE_HARNESS=$VERBOSE_HARNESS"
echo "$THIS: SANDBOX_CLEAN_CACHE=$SANDBOX_CLEAN_CACHE"

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
echo "$THIS: seconds it took to get to end of $(pwd)/$LOCAL_SANDBOX_DIR cleanup: $(($(date "+%s") - START))s"


rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

git clone --depth 1 --branch "$SANDBOX_BRANCH" --single-branch "$SANDBOX_URL" "$LOCAL_SANDBOX_DIR"

cp .env "$LOCAL_SANDBOX_DIR"/.

SANDBOX_CFG="config.harness"
echo "$THIS: about to envsubst < $SANDBOX_CFG  > $LOCAL_SANDBOX_DIR/$SANDBOX_CFG"
envsubst < "$SANDBOX_CFG" > "$LOCAL_SANDBOX_DIR/$SANDBOX_CFG"

echo "$THIS: resulting $(pwd)/$LOCAL_SANDBOX_DIR/$SANDBOX_CFG:"
cat "$LOCAL_SANDBOX_DIR/$SANDBOX_CFG"

echo ""
echo "$THIS: seconds it took to get to end of cloning sandbox into $(pwd)/$LOCAL_SANDBOX_DIR: $(($(date "+%s") - START))s"
echo ""
echo "$THIS: bringing up network with TYPE=$TYPE configuration."

pushd "$LOCAL_SANDBOX_DIR"

[[ "$VERBOSE_HARNESS" = 1 ]] && V_FLAG="-v" || V_FLAG=""


[[ "$SANDBOX_CLEAN_CACHE" = 0 ]] || touch .clean

error=0
handle_error() {
  local exit_code=$?
  echo "$THIS: trapped an error with exit_code=$exit_code!!!!"
  if [ $exit_code -ne 0 ]; then
    error=$exit_code 
  fi
}

trap handle_error ERR

set +e
echo "$THIS: running sandbox with command [./sandbox up harness $V_FLAG]"
./sandbox up harness "$V_FLAG"
if [ -n "$V_FLAG" ] ; then
  echo "----------------------------------------"
  echo "$THIS: sandbox docker-compose logs indexer-db:"
  ./sandbox dump indexer-db
  echo "----------------------------------------"
  echo "$THIS: sandbox docker-compose logs algod:"
  ./sandbox dump algod
  echo "----------------------------------------"
  echo "$THIS: sandbox docker-compose logs indexer:"
  ./sandbox dump indexer
  echo "----------------------------------------"
  echo "$THIS: sandbox docker-compose logs conduit:"
  ./sandbox dump conduit
  echo "----------------------------------------"
fi
echo "$THIS: seconds it took to finish getting sandbox harness ($(pwd)) up and running: $(($(date "+%s") - START))s"
set -e

if [ "$error" -ne 0 ]; then
  echo "$THIS: exiting with error=$error!!!!"
  exit "$error"
fi
