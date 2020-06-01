#!/usr/bin/env bash
#
# Create cucumber example tables for app transactions
#
# Must have an applications-enabled version of goal on the path, and any running node.


# this is mandatory, 'goal app' currently only supports looking up fee/first-valid/last-valid
DATA_DIR="/home/will/algorand/networks/applications-test/Node"
ACCOUNT_1=I3345FUQQ2GRBHFZQPLYQQX5HJMMRZMABCHRLWV6RCJYC6OO4MOLEUBEGU 

# Parse arguments
OPTS=`getopt -o hd: --long help,data: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    -d | --data) DATA_DIR="$2"; shift; shift ;;
    -h | --help) echo "Provide a data directory."; exit 0 ;;
    * ) break ;;
  esac
done

app_create_header() {
  echo "Example:"
  echo "  | creator | approval-prog-file | clear-prog-file | global-bytes | global-ints | local-bytes | local-ints | app-args | golden |"
}

app_create_row() {
  goal app create \
    --creator $1 \
    --approval-prog-raw $2 \
    --clear-prog-raw $3 \
    --global-byteslices $4 \
    --global-ints $5 \
    --local-byteslices $6 \
    --local-ints $7 \
    --app-arg $8 \
    -o tmp.txn \
    -d ${DATA_DIR}

  GOLDEN=$(base64 -w 0 < tmp.txn)
  rm tmp.txn

  echo "| $1 | $2 | $3 | $4 | $5 | $6 | $7 | $8 | ${GOLDEN} |"

  unset GOLDEN
}

cd programs
goal clerk compile *teal
cd ..

app_create_header
app_create_row "${ACCOUNT_1}" "programs/loccheck.teal.tok" "programs/one.teal.tok" 1 0 1 0 "str:hello"
#app_create_row "${ACCOUNT_1}" "programs/loccheck.teal.tok" programs/zero.teal.tok 1 0 1 0 "str:goodbye"
#app_create_row "${ACCOUNT_1}" "programs/loccheck.teal.tok" programs/zero.teal.tok 1 0 20 10 "str:goodbye"
