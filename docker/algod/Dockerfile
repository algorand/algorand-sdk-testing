FROM ubuntu:19.10

ENV DEBIAN_FRONTEND noninteractive

# Basic dependencies.
ENV HOME /opt
RUN apt-get update && apt-get install -y apt-utils curl git git-core bsdmainutils python3

# Copy scripts into the container.
COPY . /tmp

# Install and configure algod.
RUN python3 /tmp/docker/algod/setup.py install\
 --algod-config /tmp/config_future \
 --network-dir /opt/testnetwork \
 --network-template /tmp/network_config/template.json \
 --network-token aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
 --algod-port 60000 \
 --kmd-port 60001

# Start algod
CMD ["/usr/bin/env", "bash", "-c", "python3 /tmp/docker/algod/setup.py start --algod-config /tmp/config_future --network-dir /opt/testnetwork --never-exit"]
