FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# This didn't work
#COPY ./scripts/docker/install_dependencies.sh /opt/install_dependencies.sh
#RUN /opt/install_dependencies.sh

# Basic dependencies
RUN apt-get update && apt-get install -y apt-utils curl git git-core bsdmainutils

# Install python dependencies
ENV HOME /opt
ENV PYENV_ROOT $HOME/pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN apt-get install -y curl gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev libffi-dev
RUN git clone https://github.com/pyenv/pyenv.git $HOME/pyenv

RUN eval "$(pyenv init -)" && \
    pyenv install 3.7.1 && \
    pyenv global 3.7.1 && \
    pip install --upgrade pip && \
    pyenv rehash

# This might make it so pyenv init isn't necessary
#ENV PATH=$PYENV_ROOT/shims

RUN eval "$(pyenv init -)" \
    && pip3 install git+https://github.com/algorand/py-algorand-sdk/ -q \
    && pip3 install behave -q

# Install Javascript dependencies
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs

# Install Java dependencies
RUN apt-get install -y maven default-jdk

# Install Go dependencies
ARG GOLANG_VERSION=1.12.16
RUN curl https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz -o $HOME/go.tar.gz
RUN tar -xvf $HOME/go.tar.gz -C /usr/local
ENV GOROOT /usr/local/go
ENV GOPATH $HOME/go
ENV PATH $GOROOT/bin:$PATH

RUN mkdir -p $HOME/sdk-testing
WORKDIR $HOME/sdk-testing
CMD ["/bin/bash"]
