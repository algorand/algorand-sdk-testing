#!/usr/bin/env bash
#
# Bring up the SDK test environment.

set -e

rootdir=`dirname $0`
pushd $rootdir/.. > /dev/null

# Defaults
TYPE_OVERRIDE=""
DAEMON_FLAG="-d"
SKIP_BUILD=0
SHOW_HELP=0
ENV_FILE=".up-env"

show_help() {
  echo "Manage bringing up the SDK test environment."
  echo
  echo "Usage: up.sh [options]"
  echo
  echo "Options:"
  echo "  -f <FILE>  Override the environment file."
  echo "  -t <TYPE>  Override the installation type specified in the environment file."
  echo "             Valid types: ['channel', 'type']"
  echo "  -s         Skip rebuilding the docker image."
  echo "  -i         Start the docker environment in interactive mode."
  echo "  -h         Provide this help information."
}

# Parse arguments
while getopts "f:t:sih" opt; do
  case "$opt" in
    f) ENV_FILE=$OPTARG; ;;
    i) unset DAEMON_FLAG; ;;
    s) SKIP_BUILD=1; ;;
    t) TYPE_OVERRIDE=$OPTARG; ;;
    h) show_help; exit 0 ;;
  esac
done

# Verify there are no positional parameters with getopt/getopts
shift "$((OPTIND-1))"
if [[ "$1" != "" ]]; then
  echo "No positional arguments should be provided, found '$@'"
  echo
  show_help
  exit
fi

# Load environment.
source $ENV_FILE

# Choose which dockerfile to use.
TYPE=${TYPE_OVERRIDE:-$TYPE}
if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  export TYPE="$TYPE"
else
  echo "Unknown environment: $TYPE"
  exit 1
fi

echo "Bringing up network with '$TYPE' configuration."

# Make sure it isn't running
./scripts/down.sh

# Remove the containers to allow re-running stateful tests.
docker-compose rm --force

# When developing, it's often useful to skip the build phase.
if [[ $SKIP_BUILD -eq 0 ]]; then
  docker-compose build --no-cache --parallel
fi

docker-compose up $DAEMON_FLAG
