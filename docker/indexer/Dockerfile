FROM ubuntu:19.10

ENV DEBIAN_FRONTEND noninteractive

COPY indexer /tmp/indexer
COPY docker/indexer/setup.sh /tmp/setup.sh
COPY docker/indexer/e2edata.tar.bz2 /tmp/e2edata.tar.bz2

RUN tar -jxf /tmp/e2edata.tar.bz2 -C /tmp

CMD ["/tmp/setup.sh"]
