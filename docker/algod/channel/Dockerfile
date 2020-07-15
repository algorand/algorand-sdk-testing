FROM ubuntu:19.10

ARG CHANNEL=nightly
ENV BIN_DIR="$HOME/node"

ENV DEBIAN_FRONTEND noninteractive

RUN echo "Installing from channel: ${CHANNEL}"

# Basic dependencies.
ENV HOME /opt
RUN apt-get update && apt-get install -y apt-utils curl git git-core bsdmainutils python3

# Copy everything into the container.
COPY . /tmp

# Install algod binaries from a channel.
RUN python3 /tmp/docker/algod/setup.py install \
 --bin-dir "${BIN_DIR}" \
 --channel "${CHANNEL}"

RUN python3 /tmp/docker/algod/setup.py configure \
 --bin-dir "${BIN_DIR}" \
 --network-dir /opt/testnetwork \
 --network-template /tmp/network_config/future_template.json \
 --network-token aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
 --algod-port 60000 \
 --kmd-port 60001
 

# Start algod
CMD ["/usr/bin/env", "bash", "-c", "python3 /tmp/docker/algod/setup.py start --bin-dir \"$BIN_DIR\" --network-dir \"/opt/testnetwork\" --copy-genesis-to \"/genesis-file\""]
