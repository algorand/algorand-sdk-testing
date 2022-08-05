#!/usr/bin/env bash
#
# Bring up the SDK test environment.

set -e

# Defaults
TYPE_OVERRIDE=""
ENV_FILE=".up-env"

# TODO: THESE ARE PROBABLY ALL OBSOLETE... SHOULD REALLY PASS THRU TO SANDBOXES EXECUTABLE...
show_help() {
  echo "Manage bringing up the SDK test environment."
  echo
  echo "Usage: up.sh [options]"
  echo
  echo "Options:"
  echo "  -f <FILE>  Override the environment file."
  echo "  -t <TYPE>  Override the installation type specified in the environment file."
  echo "             Valid types: ['channel', 'type']"
  echo "  -i         Start the docker environment in interactive mode."
  echo "  -h         Provide this help information."
}

# Parse arguments
while getopts "f:t:h" opt; do
  case "$opt" in
    f) ENV_FILE=$OPTARG; ;;
    t) TYPE_OVERRIDE=$OPTARG; ;;
    *) show_help; exit 0 ;;
  esac
done


# Load environment.
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

rootdir=$(dirname "$0")
pushd "$rootdir"/.. > /dev/null || exit

rm -rf "$SANDBOX"
SANDBOX_BRANCH="configurable-ports"
git clone --branch $SANDBOX_BRANCH --single-branch https://github.com/algorand/sandbox.git $SANDBOX

echo "Bringing up network with '$TYPE' configuration."
cp .env $SANDBOX/.
cp "config.$TYPE" $SANDBOX/.
pushd "$SANDBOX"

./sandbox up "$TYPE"