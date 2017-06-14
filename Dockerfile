FROM ubuntu:16.04
RUN apt-get update && apt-get install -y --no-install-recommends \ 
  automake \
  bison \
  build-essential \
  bzip2 \
  ca-certificates \
  clang \
  checkinstall \
  cpio \
  curl \
  file \
  g++-multilib \
  gcc-multilib \
  git \
  gobject-introspection \
  gzip \
  intltool \
  libgirepository1.0-dev \
  libgsf-1-dev \
  libreadline-dev \
  libssl-dev \
  libtool \
  libxml2-dev \
  libyaml-dev \
  llvm-dev \
  make \
  patch \
  ruby \
  sed \
  uuid-dev \
  valac \
  wget \
  xz-utils \
  zlib1g-dev 

# install wslay
RUN apt-get install -y python-pip
RUN pip install sphinx
WORKDIR /home/mruby/src
RUN git clone https://github.com/tatsuhiro-t/wslay
WORKDIR /home/mruby/src/wslay
RUN autoreconf -i
RUN automake
RUN autoconf
RUN ./configure --prefix=/home/mruby/opt/wslay
RUN make
ENV PKG_CONFIG_PATH=/home/mruby/opt/wslay:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/home/mruby/wslay/lib:$LD_LIBRARY_PATH

# install libressl
WORKDIR /home/mruby/src
RUN curl http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.5.4.tar.gz | tar -xzv
RUN mv /home/mruby/src/libressl-2.5.4 /home/mruby/src/libressl
WORKDIR /home/mruby/src/libressl
RUN ./configure --prefix=/home/mruby/opt/libressl
RUN make && make check
RUN make install
ENV PKG_CONFIG_PATH=/home/mruby/opt/libressl:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/home/mruby/libressl/lib:$LD_LIBRARY_PATH

ENV SHELL /bin/bash
WORKDIR /home/mruby/code
