#!/bin/bash

TEMP=$(dirname "$(mktemp -u)")
NETWORK_NAME="sdknet"
NETWORK_DIR="/$TEMP/$NETWORK_NAME/"

goal kmd stop -d "$NETWORK_DIR/Primary"
goal network stop -r "$NETWORK_DIR"
goal network delete -r "$NETWORK_DIR"
