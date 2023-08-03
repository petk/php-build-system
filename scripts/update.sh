#!/bin/sh
#
# Download latest PHP Autotools and Windows build system files from the php-src.
# This script is intended to follow the changes in the build system and
# integrate them in the CMake system.

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
PHP build system downloader

Helper script that fetches latest php-src repository changes and copies PHP
build files from the php-src repository for easier following of the upstream
build system changes.

SYNOPSIS:
  update [<options>]

OPTIONS:
  -h, --help      Display this help.

HELP:
  To fetch latest php-src changes and copy build system files run:

    ./update
HELP
    exit 0
  fi

  shift
done

# Clone a fresh latest php-src repo.
if test ! -d "php-src"; then
  git clone --depth 1 https://github.com/php/php-src ./php-src
fi

cd php-src

# Fetch latest php-src repository changes.
git checkout .
git clean -dffx .
git pull --rebase

# Create main/php_config.h.in.
./buildconf

cd ..

# Autotools build system files.
autotools="
configure.ac
buildconf
build/*
ext/*/config0.m4
ext/*/config.m4
ext/*/config9.m4
ext/*/Makefile.frag
ext/*/*/Makefile.frag
main/build-defs.h.in
main/php_config.h.in
pear/*
sapi/*/config0.m4
sapi/*/config.m4
sapi/*/config9.m4
sapi/*/Makefile.frag
scripts/*
TSRM/*.m4
Zend/*.m4
Zend/Makefile.frag
"

rm -rf autotools
cd php-src

for file in $autotools; do
  if test -f $file; then
    echo "Copying autotools/${file}"
    dir=$(dirname "$file")
    mkdir -p ../autotools/$dir
    cp -R -- "${file}" "../autotools/${dir}"
  fi
done

# Windows build system files.
windows="
buildconf.bat
ext/*/config.w32
ext/*/*/Makefile.frag.w32
ext/*/Makefile.frag.w32
ext/*/*.def
pear/fetch.php
sapi/*/config.w32
TSRM/*.w32
win32/*
win32/build/*
Zend/zend_config.w32.h
"

cd ..
rm -rf windows
cd php-src

for file in $windows; do
  if test -f $file; then
    echo "Copying windows/${file}"
    dir=$(dirname "$file")
    mkdir -p ../windows/$dir
    cp -R -- "${file}" "../windows/${dir}"
  fi
done