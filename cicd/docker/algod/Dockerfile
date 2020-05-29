FROM ubuntu:19.10

ARG CHANNEL=nightly
ENV CHANNEL=${CHANNEL}
ENV ALGOD_PORT=60000
ENV KMD_PORT=60001
ENV NETWORK_TOKEN=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa


ENV DEBIAN_FRONTEND noninteractive

# Basic dependencies.
ENV HOME /opt
RUN apt-get update && apt-get install -y apt-utils curl git git-core bsdmainutils python3

# Copy algod scripts to image.
COPY cicd/docker/algod /algod
COPY network_config /network_config

# Install algod package.
RUN python3 /algod/setup.py install \
        --bin-dir "$HOME/node" \
        --channel "${CHANNEL}"
RUN python3 /algod/setup.py create-network \
        --bin-dir "$HOME/node" \
        --network-dir /opt/testnetwork \
        --network-template /network_config/future_template.json

ENV UPDATE_ON_START=false

ENTRYPOINT [ "bash", "-c", "/algod/entrypoint.sh" ]
