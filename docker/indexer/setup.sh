#!/bin/bash
set -e

/tmp/indexer import \
  -P "host=indexer-db port=5432 user=algorand password=harness dbname=postgres sslmode=disable" \
  --genesis "/tmp/algod/genesis.json" \
  /tmp/blocktars/*
/tmp/indexer daemon \
  -P "host=indexer-db port=5432 user=algorand password=harness dbname=postgres sslmode=disable"
sleep infinity
