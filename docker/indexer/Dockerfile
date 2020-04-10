FROM ubuntu:19.10

ENV DEBIAN_FRONTEND noninteractive

COPY indexer /tmp/indexer

CMD ["/bin/bash", "-c", "/tmp/indexer daemon -P \"host=indexer-db port=5432 user=algorand password=harness dbname=postgres sslmode=disable\""]
