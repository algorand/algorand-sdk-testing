#!/bin/bash

REPO_ROOT="$( cd "$(dirname "$0")" || exit; pwd -P )"/../..
TEMP=$(dirname "$(mktemp -u)")
NETWORK_NAME="sdknet"
NETWORK_DIR="$TEMP/$NETWORK_NAME/"

goal network stop -r "$NETWORK_DIR"
rm -rf "$NETWORK_DIR"
goal network create -n "$NETWORK_NAME" -r "$NETWORK_DIR" -t "$REPO_ROOT/network_config/future_template.json"

jq '. += {"Archival":true,"isIndexerActive":true,"EnableDeveloperAPI":true} | .EndpointAddress="127.0.0.1:60000"' \
  < "$NETWORK_DIR/Primary/config.json" \
  > "$NETWORK_DIR/Primary/config.json.new"
rm "$NETWORK_DIR/Primary/config.json"
mv "$NETWORK_DIR/Primary/config.json.new" "$NETWORK_DIR/Primary/config.json"

echo 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' > "$NETWORK_DIR/Primary/algod.token"
echo 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' > "$NETWORK_DIR/Primary/kmd-v0.5/kmd.token"
echo '{"address":"127.0.0.1:60001", "allowed_origins":["*"]}' > "$NETWORK_DIR/Primary/kmd-v0.5/kmd_config.json"

goal network start -r "$NETWORK_DIR"
goal kmd start -d "$NETWORK_DIR/Primary"
