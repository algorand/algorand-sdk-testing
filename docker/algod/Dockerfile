FROM ubuntu:19.10

ENV DEBIAN_FRONTEND noninteractive

# Basic dependencies
ENV HOME /opt
RUN apt-get update && apt-get install -y apt-utils curl git git-core bsdmainutils python3

# Install algorand-sdk-testing script dependencies
#RUN pip3 install gitpython

COPY config_future /tmp/config
COPY network_config/config.json /tmp/config.json
COPY network_config/template.json /tmp/template.json
COPY docker/setup.py /tmp/setup.py

RUN python3 /tmp/setup.py install\
 --algod-config /tmp/config \
 --network-dir /opt/testnetwork \
 --network-template /tmp/template.json \
 --network-token aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
 --algod-port 60000 \
 --kmd-port 60001

CMD ["/usr/bin/env", "bash", "-c", "python3 /tmp/setup.py start --algod-config /tmp/config --network-dir /opt/testnetwork --never-exit"]
