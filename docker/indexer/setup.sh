#!/bin/bash
set -ex

echo "Starting indexer with DB: ${DATABASE_NAME}"

# Extract the correct dataset
ls -lh  /tmp
echo "Extracting /tmp/${DATABASE_NAME}.tar.bz2"
tar -jxf "/tmp/${DATABASE_NAME}.tar.bz2" -C /tmp

/tmp/algorand-indexer import \
  -P "host=indexer-db port=5432 user=algorand password=harness dbname=$DATABASE_NAME sslmode=disable" \
  --genesis "/tmp/algod/genesis.json" \
  /tmp/blocktars/*

/tmp/algorand-indexer daemon \
  -P "host=indexer-db port=5432 user=algorand password=harness dbname=$DATABASE_NAME sslmode=disable"
sleep infinity
