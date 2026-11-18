#!/bin/bash
set -e

ROOT=$( realpath "$( dirname "$0" )" )

cd "$ROOT"
git submodule update --init --recursive

cd "$ROOT/go-algorand" && make libsodium

cd "$ROOT"
go run main.go
