set -e

if [ $UPDATE_ON_START = true ]; then
  if [ -z ${ALGOD_VERSION} ]; then
    python3 /algod/setup.py install \
      --bin-dir "$HOME/node" \
      --channel "${CHANNEL}"
  else
    python3 /algod/setup.py install \
      --bin-dir "$HOME/node" \
      --channel "${CHANNEL}"
      --algod-version ${ALGOD_VERSION}
  fi
fi

mkdir -p /opt/testnetwork

python3 /algod/setup.py configure-network \
    --network-dir /opt/testnetwork \
    --network-token ${NETWORK_TOKEN} \
    --algod-port ${ALGOD_PORT} \
    --kmd-port ${KMD_PORT}

python3 /algod/setup.py start \
    --bin-dir "$HOME/node" \
    --network-dir "/opt/testnetwork"

sleep infinity
