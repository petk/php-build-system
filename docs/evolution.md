# PHP build system evolution

## PHP 1 (1995)

First public release of PHP 1 - Personal Home Page Tools started with a single
Makefile.

<details>
  <summary>PHP tools Makefile</summary>

  ```Makefile
  #
  # Makefile for the PHP Tools
  #
  # By Rasmus Lerdorf
  #

  #
  # Here are the configurable options.
  #
  # For BSDi systems, use: -DFLOCK
  # For SVR4 systems (Solaris - SunOS 5.4), use: -DLOCKF
  # For SunOS systems use: -DFLOCK -DFILEH
  # For AIX systems use: -DLOCKF -DLOCKFH
  # For Linux use: -DLOCKF
  # For BSD 4.3 use: -DFLOCK -DFILEH -DDIRECT
  #
  # If you want to disable the <!--!command--> feature add this: -DNOSYSTEM

  OPTIONS = -DFLOCK

  # Generic compiler options
  #CFLAGS = -g -O2 -Wall -DDEBUG $(OPTIONS)
  CFLAGS = -O2 $(OPTIONS)
  CC = gcc
  # If you don't have gcc, use these instead:
  #CFLAGS = -g $(OPTIONS)
  #CC = cc

  TSOURCE = php/phpf.c php/phpl.c php/phplview.c php/phplmon.c php/common.c \
        php/error.c php/post.c php/wm.c php/common.h php/config.h \
        php/subvar.c php/html_common.h php/post.h php/version.h php/wm.h \
        php/Makefile php/README php/License

  SOURCE = phpf.c phpl.c phplview.c phplmon.c common.c \
        error.c post.c wm.c common.h config.h \
        subvar.c html_common.h post.h version.h wm.h \
        Makefile README License

  ALL: phpl.cgi phplmon.cgi phplview.cgi phpf.cgi

  phpl.cgi: phpl.o wm.o common.o post.o subvar.o error.o
      $(CC) -o phpl.cgi phpl.o wm.o common.o post.o error.o subvar.o

  phplmon.cgi: phplmon.o common.o
      $(CC) -o phplmon.cgi phplmon.o common.o

  phplview.cgi: phplview.o common.o post.o error.o
      $(CC) -o phplview.cgi phplview.o common.o post.o error.o

  phpf.cgi: phpf.o post.o error.o
      $(CC) -o phpf.cgi phpf.o post.o error.o common.o

  php.tar: $(SOURCE)
      cd ..;tar -cf php/php.tar $(TSOURCE);cd php

  error.o:    error.c html_common.h
  phpl.o:     phpl.c config.h
  phplmon.o:  phplmon.c config.h
  phplview.o: phplview.c
  wm.o:       wm.c
  common.o:   common.c version.h common.h
  post.o:     post.c html_common.h
  phpf.o:     phpf.c html_common.h common.h
  subvar.o:   subvar.c
  ```
</details>

## PHP 2.0 (1998)

PHP quickly grew and a new version was created - PHP 2.0 (PHP/FI) with Autoconf
2.9 based configure script.

## PHP 4.0 (2000)

In 1999, support for building external PHP extensions using a PEAR-based tool
`phpize` was added to PHP which became available in 2000 in the PHP 4.0 release.
Autoconf minimum required version was set to `2.13`.

## PHP 4.3 (2002)

Build system gets rewritten and modernized for the Autoconf versions available
at the time. Dependency on Automake has been removed.

## PHP 5.0 (2004)

In 2003, a new additional Windows dedicated build system for building PHP on
Windows systems was developed and added to PHP 5.0 released in 2004.
Freedesktop's `pkg-config` tool was optionally used in PHP Autotools-based *nix
build system to find the OpenSSL dependency on the system.

## 2008

Idea to rewrite PHP build system in CMake first appeared during the Google
Summer of Code in 2008 ([wiki](https://wiki.php.net/internals/cmake),
[php-cmake](https://github.com/gloob/php-cmake)).

## PHP 5.4 (2012)

Autoconf minimum required version was increased to `2.59`.

## PHP 7.2 (2015)

The `configure.in` was renamed to `configure.ac` according to Autoconf
evolution. Autoconf minimum required version was increased to `2.64`.

## PHP 7.3 (2018)

Autoconf minimum required version was increased to `2.68`.

## PHP 7.4 (2019)

In 2018, support for Freedesktop's `pkg-config` M4 macros was added in the PHP
repository to simplify finding system dependencies. In 2019, build system was
heavily cleaned up and adjusted for Autoconf versions available at the time,
including the removal of `aclocal.m4` in favor of the php related M4 macros in
`php.m4`.

## PHP 8.0 (2020)

PHP coding standards now use the C99 standard.

## 2021

Idea to move CMake forward and additionally use Conan was started on the
[PHP internals mailing list](https://externals.io/message/116655).

## PHP 8.3 (2023)

Windows 8 became the minimum supported version by the PHP Windows build system.

## PHP 8.4 (2024)

Autotools-based build system was cleaned-up, updated, and refactored using the
current Autoconf syntax for the current systems at the time. Cross-compiling was
improved one step forward with cache variables synced enabling the manual
overrides on many places. C preprocessor macros inconsistencies between Windows
and Autotools configuration headers were synced to a nearly identical behavior.

## PHP 8.5 (2025)

PHP coding standards now use the C11 standard.
