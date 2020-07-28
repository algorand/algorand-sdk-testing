#!/usr/bin/env bash
#
# Provide the full path to a Makefile
#    ./implements_all_tests.sh /path/to/go-algorand-sdk/Makefile
rootdir=`dirname $0`
pushd $rootdir/.. > /dev/null

EXCLUSIONS=("@algod" "@unit")

isExcluded () {
  local e
  match="$1"
  shift
  for e in ${EXCLUSIONS[@]}; do
    [[ "$e" == "$match" ]] && return 0;
  done
  return 1
}

# Lookup tags
TAGS=$(find . -name "*.feature" -exec cat {} \; -exec /usr/bin/echo \;|grep @|tr -d ' '|sort -u)


if ! [ -r $1 ]; then
  printf "Unable to read makefile at '$1'\n"
  exit 1
fi

print "Checking that '$1' contains all of the tags."

for t in $TAGS; do
  if ! isExcluded $t; then
    if ! grep -q $t $1; then
      printf "Missing tag: $t\n"
    fi
  fi
done
