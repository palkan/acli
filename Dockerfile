FROM ubuntu:16.04
# RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends \ 
  automake \
  bison \
  build-essential \
  bzip2 \
  ca-certificates \
  clang \
  cpio \
  curl \
  debhelper \
  file \
  g++-multilib \
  gcc-multilib \
  genisoimage \
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
  mingw-w64 \
  patch \
  rpm \
  sed \
  uuid-dev \
  valac \
  wget \
  xz-utils \
  zlib1g-dev 

## build sodium
WORKDIR /root
RUN git clone https://github.com/jedisct1/libsodium /root/libsodium
WORKDIR /root/libsodium
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make && make check
RUN make install

# install wslay
RUN apt-get install -y --force-yes python-sphinx
RUN git clone https://github.com/tatsuhiro-t/wslay /root/wslay
WORKDIR /root/wslay
RUN autoreconf -i
RUN automake
RUN autoconf
RUN ./configure --prefix=/usr
RUN make

# install libressl-portable
# WORKDIR /root
# RUN git clone https://github.com/libressl-portable/portable
# WORKDIR /root/portable
# RUN ./autogen.sh
# RUN ./configure --prefix=/usr
# RUN make && make check
# RUN make install

# install ruby
RUN mkdir -p /opt/ruby-2.2.2/ && \
  curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/cedar-14/ruby-2.2.2.tgz | tar xzC /opt/ruby-2.2.2/
ENV PATH /opt/ruby-2.2.2/bin:$PATH

# install fpm to build packages (deb, rpm)
RUN gem install fpm --no-document

# install osx cross compiling tools
RUN cd /opt/ && \
  git clone https://github.com/tpoechtrager/osxcross.git
COPY MacOSX10.11.sdk.tar.xz /opt/osxcross/tarballs/
RUN echo "\n" | bash /opt/osxcross/build.sh
RUN rm /opt/osxcross/tarballs/*
ENV PATH /opt/osxcross/target/bin:$PATH
ENV SHELL /bin/bash

# install msitools
RUN cd /tmp && wget https://launchpad.net/ubuntu/+archive/primary/+files/gcab_0.6.orig.tar.xz && tar -xf gcab_0.6.orig.tar.xz && cd gcab-0.6 && ./configure && make && make install

RUN cd /tmp && wget https://launchpad.net/ubuntu/+archive/primary/+files/msitools_0.94.orig.tar.xz && tar -xf msitools_0.94.orig.tar.xz && cd msitools-0.94 && ./configure && make && make install

# Add pry-byebug to debug build process
RUN gem install pry-byebug

WORKDIR /home/mruby/code
