#!/bin/bash
set -e

/tmp/algorand-indexer import \
  -P "host=indexer-db port=${DATABASE_PORT} user=${DATABASE_USERNAME} password=${DATABASE_PASSWORD} dbname=${DATABASE_NAME} sslmode=disable" \
  --genesis "/tmp/algod/genesis.json" \
  /tmp/blocktars/*
/tmp/algorand-indexer daemon \
  -P "host=indexer-db port=${DATABASE_PORT} user=${DATABASE_USERNAME} password=${DATABASE_PASSWORD} dbname=${DATABASE_NAME} sslmode=disable"
sleep infinity
