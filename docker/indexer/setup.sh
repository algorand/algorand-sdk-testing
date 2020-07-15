#!/bin/bash

# Start indexer daemon. There are various configurations controlled by
# environment variables.
#
# Configuration:
#   TYPE [snapshot]   - load a snapshot, start indexer in readonly mode.
#        [live    ]   - connect to an existing algod instance.
#   CONNECTION_STRING - the postgres connection string to use.
#   SNAPSHOT_FILE     - snapshot to import.
#
# Volume:
#   /genesis-file/genesis.json - Must be mounted when connecting to algod.
set -e


TYPE="${TYPE:-snapshot}"

start_with_algod() {
  echo "Starting indexer against algod."

  /tmp/algorand-indexer daemon \
    --algod-net "algod:60000" \
    --algod-token aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
    --genesis "/genesis-file/genesis.json" \
    -P "$CONNECTION_STRING"
}

import_and_start_readonly() {
  echo "Starting indexer with DB."

  # Extract the correct dataset
  ls -lh  /tmp
  echo "Extracting ${SNAPSHOT_FILE}"
  tar -xf "${SNAPSHOT_FILE}" -C /tmp

  /tmp/algorand-indexer import \
    -P "$CONNECTION_STRING" \
    --genesis "/tmp/algod/genesis.json" \
    /tmp/blocktars/*

  /tmp/algorand-indexer daemon -P "$CONNECTION_STRING"
}

case $TYPE in
  live)     start_with_algod ;;
  snapshot) import_and_start_readonly ;;
  *)        echo "Unknown setup type: $TYPE" && help && exit 1 ;;
esac

sleep infinity
