FROM ubuntu:19.10

ENV DEBIAN_FRONTEND noninteractive

ENV DATABASE_PORT=5432
ENV DATABASE_USERNAME=algorand
ENV DATABASE_PASSWORD=harness

ADD https://algorand-testdata.s3.amazonaws.com/indexer/algorand-indexer /tmp/algorand-indexer
RUN chmod +x /tmp/algorand-indexer

COPY cicd/docker/indexer/setup.sh /tmp/setup.sh
COPY cicd/docker/indexer/e2edata.tar.bz2 /tmp/e2edata.tar.bz2
COPY cicd/docker/indexer/init-scripts /docker-entrypoint-initdb.d

RUN tar -jxf /tmp/e2edata.tar.bz2 -C /tmp

CMD ["/tmp/setup.sh"]
