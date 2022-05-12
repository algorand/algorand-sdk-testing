FROM golang:1.17-alpine

ARG URL=https://github.com/algorand/indexer
ARG BRANCH=master
ARG SHA=""

RUN echo "Installing from source. ${URL} -- ${BRANCH} -- ${SHA}"

RUN apk update && apk add --no-cache --update \
        alpine-sdk git bzip2 make bash libtool autoconf automake boost-dev musl-dev

# Install indexer binaries.
RUN git clone --single-branch --branch "${BRANCH}" "${URL}" /opt/indexer
ENV HOME /opt/indexer
WORKDIR /opt/indexer
RUN if [ "${SHA}" != "" ]; then echo "Checking out ${SHA}" && git checkout "${SHA}"; fi
RUN make
RUN cp cmd/algorand-indexer/algorand-indexer /tmp

ENV DEBIAN_FRONTEND noninteractive

COPY docker/indexer/setup.sh /tmp/setup.sh
COPY docker/indexer/data/* /tmp/

RUN ls -lh /tmp

CMD ["/tmp/setup.sh"]
