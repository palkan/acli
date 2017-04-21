#!/bin/sh
# The purpose of this file is to install wslay in
# the Travis CI environment. Outside this environment,
# you would probably not want to install it like this.

set -e

# check if wslay is already installed
if [ ! -d "$HOME/wslay/lib" ]; then
  git clone https://github.com/tatsuhiro-t/wslay
  cd wslay
  autoreconf -i
  automake
  autoconf
  ./configure --prefix=/usr
  make
else
  echo 'Using cached directory.'
fi
