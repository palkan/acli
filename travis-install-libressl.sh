#!/bin/sh
# The purpose of this file is to install libressl in
# the Travis CI environment. Outside this environment,
# you would probably not want to install it like this.

set -e

# check if libressl is already installed
if [ ! -d "$HOME/opt/libressl/lib" ]; then
  cd $HOME
  git clone --branch v3.0.2 https://github.com/libressl-portable/portable libressl
  cd libressl
  ./autogen.sh
  ./configure --prefix="${HOME}/opt/libressl"
  make && make check
  make install
else
  echo 'Using cached directory.'
fi
