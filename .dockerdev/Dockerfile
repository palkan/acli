ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-buster

# Common dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ENV LANG=C.UTF-8

# Install mruby dependencies
COPY ./Aptfile /tmp/Aptfile
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    $(cat /tmp/Aptfile | xargs) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# Update Ruby tools
RUN gem update --system

WORKDIR /home/mruby/src

# Install wslay
RUN pip install sphinx && \
    git clone --depth 1 --branch release-1.1.0 https://github.com/tatsuhiro-t/wslay  && \
    (cd wslay && \
    autoreconf -i && \
    automake && \
    autoconf && \
    ./configure --prefix=/home/mruby/opt/wslay && \
    make) && \
    rm -rf wslay

ENV PKG_CONFIG_PATH=/home/mruby/opt/wslay:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/home/mruby/wslay/lib:$LD_LIBRARY_PATH

# Install libressl
RUN curl http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.5.4.tar.gz | tar -xzv && \
    mv /home/mruby/src/libressl-2.5.4 /home/mruby/src/libressl && \
    (cd libressl && \
    ./configure --prefix=/home/mruby/opt/libressl && \
    make && make check && \
    make install) && \
    rm -rf libressl

ENV PKG_CONFIG_PATH=/home/mruby/opt/libressl:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/home/mruby/opt/libressl/lib:$LD_LIBRARY_PATH

WORKDIR /home/mruby/code
