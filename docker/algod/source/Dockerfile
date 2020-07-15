FROM golang:1.13.12

ARG URL=https://github.com/algorand/go-algorand
ARG BRANCH=master

RUN echo "Installing from source. ${URL} -- ${BRANCH}"
ENV BIN_DIR="$GOPATH/bin"

ENV DEBIAN_FRONTEND noninteractive

# Basic dependencies.
ENV HOME /opt
RUN apt-get update && apt-get install -y apt-utils curl git git-core bsdmainutils python3

# Copy everything into the container.
COPY . /tmp

# Install algod binaries.
RUN git clone --single-branch --branch "${BRANCH}" "${URL}" && \
    cd go-algorand && \
    ./scripts/configure_dev.sh && \
    make install

# Configure private network
RUN python3 /tmp/docker/algod/setup.py configure \
 --bin-dir "$BIN_DIR" \
 --network-dir /opt/testnetwork \
 --network-template /tmp/network_config/future_template.json \
 --network-token aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
 --algod-port 60000 \
 --kmd-port 60001

# Start algod
CMD ["/usr/bin/env", "bash", "-c", "python3 /tmp/docker/algod/setup.py start --bin-dir \"$BIN_DIR\" --network-dir \"/opt/testnetwork\" --copy-genesis-to \"/genesis-file\""]
