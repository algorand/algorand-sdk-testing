#!/usr/bin/env bash
#
# Bring up the SDK test environment.

set -e

rootdir=`dirname $0`
pushd $rootdir/.. > /dev/null

# Defaults
TYPE="channel"
DAEMON_FLAG="-d"
SKIP_BUILD=0
SHOW_HELP=0

show_help() {
  echo "Manage bringing up the SDK test environment."
  echo
  echo "Usage: up.sh [options]"
  echo
  echo "Options:"
  echo "  -t, --type <TYPE>  The installation type to use. ['channel', 'type']"
  echo "  -s, --skip-build   Skip rebuilding the docker image."
  echo "  -i, --interactive  Start the docker environment in interactive mode."
  echo "  -h, --help         Provide this help information."
}

# Parse arguments
OPTS=`getopt -o hist: --long help,interactive,skip-build,type: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -s | --skip-build) SKIP_BUILD=1; shift;;
    -t | --type) TYPE="$2"; shift; shift ;;
    -i | --interactive) unset DAEMON_FLAG; shift;;
    -h | --help) show_help; exit 0 ;;
    * ) break ;;
  esac
done

shift "$((OPTIND))"
if [[ "$1" != "" ]]; then
  echo "No positional arguments should be provided, found '$@'"
  echo
  show_help
  exit
fi

# Choose which dockerfile to use.
if [[ $TYPE == "channel" ]] || [[ $TYPE == "source" ]]; then
  export TYPE=$TYPE
else
  echo "Unknown environment: $TYPE"
  exit 1
fi

# Make sure it isn't running
./scripts/down.sh

# Remove the containers to allow re-running stateful tests.
docker-compose rm --force

# When developing, it's often useful to skip the build phase.
if [[ $SKIP_BUILD -eq 0 ]]; then
  docker-compose build --no-cache
fi

docker-compose up $DAEMON_FLAG
