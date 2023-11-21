# PHP build system

[![PHP version](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&labelColor=17181B)](https://www.php.net/)
[![CMake version](https://img.shields.io/badge/CMake-3.25-064F8C?logo=cmake&labelColor=17181B)](https://cmake.org)
[![C99](https://img.shields.io/badge/standard-C99-A8B9CC?logo=C&labelColor=17181B)](https://port70.net/~nsz/c/c99/n1256.html)
[![GNU](https://img.shields.io/badge/-GNU-A42E2B?logo=gnu&labelColor=17181B)](https://www.gnu.org/)
[![Ninja](https://img.shields.io/badge/%F0%9F%A5%B7-Ninja%20build-DD6620?labelColor=17181B)](https://ninja-build.org/)

This repository delves into the core of the PHP build system, elucidating the
intricacies of how to build PHP with CMake.

![ElePHPant](docs/images/elephpant.jpg)

## Quick usage - TL;DR

```sh
# Prerequisites for Debian based distributions:
sudo apt install cmake gcc g++ bison re2c libxml2-dev libsqlite3-dev

# Prerequisites for Fedora based distributions:
sudo dnf install cmake gcc gcc-c++ bison re2c libxml2-devel sqlite-devel

# Prerequisites for FreeBSD:
sudo pkg install cmake bison re2c libxml2 sqlite3

# Clone this repository:
git clone https://github.com/petk/php-build-system

# Download latest PHP and add CMake files:
cmake -P php-build-system/bin/php.cmake

# Generate build system from sources to a new build directory:
cmake -S php-build-system/php-8.4-dev -B my-php-build

# Build PHP in parallel:
cmake --build my-php-build -j

./my-php-build/sapi/cli/php -v
```

## Index

* [1. Introduction](#1-introduction)
* [2. PHP directory structure](#2-php-directory-structure)
* [3. PHP extensions](#3-php-extensions)
* [4. PHP SAPI (Server API) modules](#4-php-sapi-server-api-modules)
* [5. Parser and lexer files](#5-parser-and-lexer-files)
* [6. \*nix build system](#6-nix-build-system)
  * [6.1. \*nix build system diagram](#61-nix-build-system-diagram)
  * [6.2. Build requirements](#62-build-requirements)
  * [6.3. The configure command-line options](#63-the-configure-command-line-options)
* [7. CMake](#7-cmake)
  * [7.1. Why using CMake?](#71-why-using-cmake)
  * [7.2. Directory structure](#72-directory-structure)
  * [7.3. CMake-based PHP build system diagram](#73-cmake-based-php-build-system-diagram)
  * [7.4. CMake usage](#74-cmake-usage)
  * [7.5. CMake minimum version for PHP](#75-cmake-minimum-version-for-php)
  * [7.6. Command-line options](#76-command-line-options)
  * [7.7. CMake generators for building PHP](#77-cmake-generators-for-building-php)
    * [7.7.1. Unix Makefiles (default)](#771-unix-makefiles-default)
    * [7.7.2. Ninja](#772-ninja)
  * [7.8. CMake presets](#78-cmake-presets)
  * [7.9. CMake GUI](#79-cmake-gui)
  * [7.10. Command-line interface ccmake](#710-command-line-interface-ccmake)
  * [7.11. Testing](#711-testing)
  * [7.12. Performance](#712-performance)
* [8. See more](#8-see-more)
  * [8.1. CMake and PHP](#81-cmake-and-php)
  * [8.2. PHP Internals](#82-php-internals)

## 1. Introduction

PHP developers typically opt for convenient methods to set up PHP on their
machines, such as utilizing prebuilt Linux packages available in their Linux
distribution repositories, deploying Docker images, or relying on user-friendly
stacks that bundle PHP, its extensions, web server, and database into a unified
installation package.

```sh
# Debian-based distributions:
sudo apt install php...

# Fedora-based distributions:
sudo dnf install php...
```

In contrast, the practice of building PHP from source code is primarily reserved
for specific purposes, such as PHP source code development or extensive
customization of PHP configurations on a particular system. This approach is
less commonly employed by everyday PHP developers due to its intricate and
time-consuming nature.

In the realm of software development, a build system is a collection of tools
and files that automate the process of compiling, linking, and assembling the
project's source code into its final form, ready to be executed. It helps
developers with repetitive tasks and ensures consistency and correctness in the
build process for various platforms and hardware out there.

A key function of a build system in the context of C/C++ software development is
to establish a structured framework that guides how C code should be written.
Beyond its primary role of compiling source files into executable programs, the
build system plays a pivotal educational role, imparting best practices and
coding standards to C developers. By enforcing consistency and adherence to
coding conventions, it fosters the creation of high-quality C and C++ code,
ultimately enhancing software maintainability and reliability.

Additionally, the build system aims to enable C developers to work efficiently
by abstracting away system-specific details, allowing them to focus on the logic
and usability of their code. When adding a new C/C++ source file or making minor
modifications, developers shouldn't have to delve into the inner workings of the
build system, sift through extensive build system documentation or extensively
explore the complexities of the underlying system.

There are numerous well-known build systems available for C projects, ranging
from the veteran GNU Autotools and the widely adopted CMake, to the efficient
Ninja, versatile SCons, adaptable Meson, and even the simplest manual usage of
Make.

PHP build system consist of two parts:

* \*nix build system (Linux, macOS, FreeBSD, OpenBSD, etc.)
* Windows build system

## 2. PHP directory structure

Before we begin, it might be useful to understand directory structure of the PHP
source code. PHP is developed at the
[php-src GitHub repository](https://github.com/php/php-src).

After cloning the repository:

```sh
git clone https://github.com/php/php-src
cd php-src
```

you end up with a large monolithic repository consisting of C source code files,
PHP tests and other files:

```sh
<php-src>/
 ├─ .git/                         # Git configuration and source directory
 ├─ appveyor/                     # Appveyor CI service files
 ├─ benchmark/                    # Benchmark some common applications in CI
 ├─ build/                        # *nix build system files
 ├─ docs/                         # PHP internals documentation
 └─ ext/                          # PHP core extensions
    └─ bcmath/                    # The bcmath PHP extension
       ├─ libbcmath/              # The bcmath library forked and maintained in php-src
       ├─ tests/                  # *.phpt test files for extension
       ├─ bcmath.stub.php         # A stub file for the bcmath extension functions
       └─ ...
    └─ curl/                      # The curl PHP extension
       ├─ sync-constants.php      # The curl symbols checker
       └─ ...
    └─ date/                      # The date/time PHP extension
       └─ lib/                    # Bundled datetime library https://github.com/derickr/timelib
          └─ ...
       └─ ...
    ├─ dl_test/                   # Extension for testing dl()
    └─ ffi/                       # The FFI PHP extension
       ├─ ffi_parser.c            # Generated by https://github.com/dstogov/llk
       └─ ...
    └─ fileinfo/                  # The fileinfo PHP extension
       ├─ libmagic/               # Modified libmagic https://github.com/file/file
       ├─ data_file.c             # Generated by `ext/fileinfo/create_data_file.php`
       ├─ libmagic.patch          # Modifications patch from upstream libmagic
       ├─ magicdata.patch         # Modifications patch from upstream libmagic
       └─ ...
    └─ gd/                        # The GD PHP extension
       ├─ libgd/                  # Bundled and modified GD library https://github.com/libgd/libgd
       └─ ...
    └─ mbstring/                  # The Multibyte string PHP extension
       ├─ libmbfl/                # Forked and maintained in php-src
       ├─ unicode_data.h          # Generated by `ext/mbstring/ucgendat/ucgendat.php`
       └─ ...
    └─ opcache/                   # The OPcache PHP extension
       └─ jit/                    # OPcache Jit
          └─ dynasm/              # DynASM ARM encoding engine
             ├─ minilua.c         # Customized Lua scripting language to build LuaJIT
             └─ ...
          ├─ zend_jit_x86.c       # Generated by minilua
          └─ ...
    └─ pcre/                      # The PCRE PHP extension
       ├─ pcre2lib/               # https://www.pcre.org/
       └─ ...
    ├─ skeleton/                  # Skeleton for developing new extensions with `ext/ext_skel.php`
    └─ standard/                  # Always enabled core extension
       └─ html_tables/
          ├─ mappings/            # https://www.unicode.org/Public/MAPPINGS/
          └─ ...
       ├─ credits_ext.h           # Generated by `scripts/dev/credits`
       ├─ credits_sapi.h          # Generated by `scripts/dev/credits`
       ├─ html_tables.h           # Generated by `ext/standard/html_tables/html_table_gen.php`
       └─ ...
    └─ tokenizer/                 # The tokenizer PHP extension
       ├─ tokenizer_data.c        # Generated by `ext/tokenizer/tokenizer_data_gen.php`
       ├─ tokenizer_data_stub.php # Generated by `ext/tokenizer/tokenizer_data_gen.php`
       └─ ...
    └─ zend_test                  # For testing internal APIs. Not needed for regular builds
       └─ ...
    └─ zip/                       # Bundled https://github.com/pierrejoye/php_zip
       └─ ...
    ├─ ...
    └─ ext_skel.php               # Helper script that creates a new PHP extension
 └─ main/                         # Binding that ties extensions, SAPIs, Zend engine and TSRM together
    ├─ streams/                   # Streams layer subsystem
    └─ ...
 ├─ modules/                      # Shared libraries, created when building PHP
 ├─ pear/                         # PEAR installation
 └─ sapi/                         # PHP SAPI (Server API) modules
    └─ cli/                       # Command-line PHP SAPI module
       ├─ mime_type_map.h         # Generated by `sapi/cli/generate_mime_type_map.php`
       └─ ...
    └─ ...
 ├─ scripts/                      # php-config, phpize and internal development scripts
 ├─ tests/                        # Core features tests
 ├─ travis/                       # Travis CI service files
 ├─ TSRM/                         # Thread safe resource manager
 └─ Zend/                         # Zend engine
    ├─ asm/                       # Bundled from src/asm in https://github.com/boostorg/context
    ├─ Optimizer/                 # For faster PHP execution through opcode caching and optimization
    ├─ tests/                     # PHP tests *.phpt files for Zend engine
    ├─ zend_vm_execute.h          # Generated by `Zend/zend_vm_gen.php`
    ├─ zend_vm_opcodes.c          # Generated by `Zend/zend_vm_gen.php`
    ├─ zend_vm_opcodes.h          # Generated by `Zend/zend_vm_gen.php`
    └─ ...
 └─ win32/                        # Windows build system files
    ├─ cp_enc_map.c               # Generated by `win32/cp_enc_map_gen.exe`
    └─ ...
 └─ ...
```

The following diagram briefly displays, how PHP libraries (in terms of a build
system) are linked together:

![Diagram how PHP libraries are linked together](docs/images/links.svg)

## 3. PHP extensions

PHP has several ways to install PHP extensions:

* Bundled

  This is the default way. Extension is built together with PHP SAPI and no
  enabling is needed in the `php.ini` configuration.

* Shared

  This installs the extension as dynamically loadable library. Extension to be
  visible in the PHP SAPI (see `php -m`) needs to be also manually enabled in
  the `php.ini` configuration:

  ```ini
  extension=php_extension_lowercase_name
  ```

  This will load the PHP extension shared library file located in the extension
  directory (the `extension_dir` INI directive). File can have `.so` extension
  on *nix systems, `.dll` on Windows, and possibly other extensions such as
  `.sl` on certain HP-UX systems, or `.dylib` on macOS.

The following extensions are always enabled and are part of the overall PHP
engine source code:

* `ext/date`
* `ext/hash`
* `ext/json`
* `ext/pcre`
* `ext/random`
* `ext/reflection`
* `ext/spl`
* `ext/standard`

PHP extensions ecosystem also consists of the [PECL](https://pecl.php.net)
extensions. These can be installed with a separate tool `pecl`:

```sh
pecl install php_extension_name
```

PECL tool is a simple shell script wrapper around the PHP code as part of the
[pear-core](https://github.com/pear/pear-core/blob/master/scripts/pecl.sh)
repository.

## 4. PHP SAPI (Server API) modules

PHP works through the concept of SAPI modules located in the `sapi` directory.

When running PHP in command line, the cli SAPI module is used:

```sh
/sapi/cli/php -v
```

* [Embed SAPI module](/docs/embed.md)

There are other SAPI modules located in the ecosystem:

* [frankenphp](https://github.com/dunglas/frankenphp)
* [ngx-php](https://github.com/rryqszq4/ngx-php)
* ...

## 5. Parser and lexer files

Some source files are generated with 3rd party tools. These include so called
parser and lexer files which are generated with [re2c](https://re2c.org/) and
[bison](https://www.gnu.org/software/bison/).

Parser files are generated from `*.y` source using `bison` tool to C source code
and header files.

Lexer files are generated from `*.l` and `*.re` source files using `re2c` tool
to C source code and header files.

There is a helper shell script available that generates all these files when
developing PHP source, otherwise they are generated upon `make` step based on
the `Makefile.frag` files.

```sh
./scripts/dev/genfiles
```

```sh
<php-src>/
 └─ build/
    ├─ php.m4                       # PHP Autoconf macros (re2c and bison macros are here)
    └─ ...
 └─ ext/
    ├─ ...
    └─ date/
       └─ lib/
          ├─ parse_date.c           # Generated by re2c 0.15.3
          ├─ parse_iso_intervals.c  # Generated by re2c 0.15.3
          └─ ...
       └─ ...
    └─ ffi/
       ├─ ffi_parser.c              # Manually generated by https://github.com/dstogov/llk
       └─ ...
    └─ json/
       ├─ json_parser.tab.c         # Generated with bison
       ├─ json_parser.tab.h         # Generated with bison
       ├─ json_parser.y             # Parser source
       ├─ json_scanner.c            # Generated with re2c
       ├─ json_scanner.re           # Lexer source
       ├─ Makefile.frag             # Makefile fragment
       ├─ php_json_scanner_defs.h   # Generated with re2c
       └─ ...
    └─ pdo/
       ├─ Makefile.frag             # Makefile fragment
       ├─ pdo_sql_parser.c          # Generated with re2c
       ├─ pdo_sql_parser.re         # Source for re2c
       └─ ...
    └─ phar/
       ├─ Makefile.frag             # Makefile fragment
       ├─ phar_path_check.c         # Generated with re2c
       ├─ phar_path_check.re        # Source for re2c
       └─ ...
    └─ standard/
       ├─ Makefile.frag             # Makefile fragment
       ├─ url_scanner_ex.c          # Generated with re2c
       ├─ url_scanner_ex.re         # Source for re2c
       ├─ var_unserializer.c        # Generated with re2c
       ├─ var_unserializer.re       # Source for re2c
       └─ ...
    └─ ...
 └─ sapi/
    └─ phpdbg/
       ├─ phpdbg_lexer.c            # Generated with re2c
       ├─ phpdbg_lexer.l            # Source for re2c
       ├─ phpdbg_parser.c           # Generated with bison
       ├─ phpdbg_parser.h           # Generated with bison
       ├─ phpdbg_parser.y           # Source for bison
       ├─ phpdbg_parser.output      # Generated with bison
       └─ ...
    └─ ...
 └─ scripts/
    └─ dev/
       ├─ genfiles                  # Parser and lexer files generator helper
       └─ ...
    └─ ...
 └─ Zend/
    ├─ Makefile.frag                # Part of Makefile related to Zend files
    ├─ zend_ini_parser.c            # Generated with bison
    ├─ zend_ini_parser.h            # Generated with bison
    ├─ zend_ini_parser.output       # Generated with bison
    ├─ zend_ini_parser.y            # Parser source
    ├─ zend_ini_scanner.c           # Generated with re2c
    ├─ zend_ini_scanner.l           # Lexer source
    ├─ zend_ini_scanner_defs.h      # Generated with re2c
    ├─ zend_language_parser.c       # Generated with bison
    ├─ zend_language_parser.h       # Generated with bison
    ├─ zend_language_parser.output  # Generated with bison
    ├─ zend_language_parser.y       # Parser source
    ├─ zend_language_scanner_defs.h # Generated with re2c
    ├─ zend_language_scanner.c      # Generated with re2c
    ├─ zend_language_scanner.l      # Lexer source
    └─ ...
 ├─ configure.ac                    # Minimum re2c and bison versions settings
 └─ ...
```

## 6. \*nix build system

\*nix build system in PHP uses [Autoconf](https://www.gnu.org/software/autoconf/)
to build a `configure` shell script that further creates main `Makefile` to
build sources to executable binaries.

```sh
./buildconf
./configure
make
```

The `buildconf` is a simple shell script wrapper around `autoconf` and
`autoheader` tools that checks required Autoconf version. It creates `configure`
command-line script and `main/php_config.h.in` header template.

When running the `./configure`, many checks are done based on the running
system. Things like C headers availability, C symbols, required library
dependencies etc.

The `configure` script creates `Makefile` where the `make` command then builds
binary files from C source files. You can optionally pass the `-j` option which
is the number of threads on current system, so it builds faster.

```sh
make -j $(nproc)
```

When compiling is done, the tests can be run with:

```sh
make TEST_PHP_ARGS=-j10 test
```

PHP \*nix build system is pretty much standard GNU Autotools build system with
few customizations. It doesn't use Automake and it bundles some 3rd party files
for easier installation across various systems out there without requiring
installation dependencies. Autotools is a veteran build system present since
early C/C++ days. It is used for most Linux ecosystem out there and it might
cause issues for C developers today.

Build system is a collection of various files across the php-src repository:

```sh
<php-src>/
 └─ build/
    ├─ ax_*.m4             # https://github.com/autoconf-archive/autoconf-archive
    ├─ config-stubs        # Adds extension and SAPI config*.m4 stubs to configure
    ├─ config.guess        # https://git.savannah.gnu.org/cgit/config.git
    ├─ config.sub          # https://git.savannah.gnu.org/cgit/config.git
    ├─ genif.sh            # Generator for the internal_functions* files
    ├─ libtool.m4          # Forked https://git.savannah.gnu.org/cgit/libtool.git
    ├─ ltmain.sh           # Forked https://git.savannah.gnu.org/cgit/libtool.git
    ├─ Makefile.global     # Root Makefile template when configure is run
    ├─ order_by_dep.awk    # Used by genif.sh
    ├─ php.m4              # PHP Autoconf macros
    ├─ pkg.m4              # https://gitlab.freedesktop.org/pkg-config/pkg-config
    ├─ print_include.awk   # Used by genif.sh
    ├─ shtool              # https://www.gnu.org/software/shtool/
    └─ ...
 └─ ext/
    └─ bcmath/
       ├─ config.m4        # Extension's Autoconf file
       └─ ...
    └─ date/
       ├─ config0.m4       # Suffix 0 is priority which includes the file before other config.m4 extension files
       └─ ...
    └─ mysqlnd/
       ├─ config9.m4       # Suffix 9 priority includes the file after other config.m4 files
       └─ ...
    └─ opcache/
       └─ jit/
          ├─ Makefile.frag # Makefile fragment for OPcache Jit
          └─ ...
       ├─ config.m4        # Autoconf file for OPcache extension
       └─ ...
    └─ ...
 └─ main/
    ├─ php_version.h       # Generated by release managers using `configure`
    └─ ...
 ├─ pear/
 └─ sapi/
    └─ cli/
       ├─ config.m4        # Autoconf M4 file for CLI SAPI
       └─ ...
    └─ ...
 ├─ scripts/
 └─ TSRM/
    ├─ threads.m4          # Autoconf macros for pthreads
    ├─ tsrm.m4             # Autoconf macros for TSRM directory
    └─ ...
 └─ Zend/
    ├─ Makefile.frag       # Makefile fragment for Zend engine
    ├─ Zend.m4             # Autoconf macros for Zend directory
    └─ ...
 ├─ buildconf              # Wrapper for autoconf and autoheader tools
 ├─ configure.ac           # Autoconf main input file for constructing configure script
 └─ ...
```

### 6.1. \*nix build system diagram

![PHP *nix build system using Autotools](docs/images/autotools.svg)

### 6.2. Build requirements

Before you can build PHP on Linux and other Unix-like systems, you must first
install certain third-party requirements. It's important to note that the names
of these requirements may vary depending on your specific system. For the sake
of simplicity, we will use generic names here. When building PHP from source,
one crucial requirement is a library containing development files. Such
libraries are typically packaged under names like `libfoo-dev`, `libfoo-devel`,
or similar conventions. For instance, to install the `libzip` library, you would
look for the `libzip-dev` (or `libzip-devel`) package.

Required:

* autoconf
* make
* gcc
* g++
* pkg-config
* libxml
* libsqlite3

Additionally required when building from Git repository source code:

* bison
* re2c

Optional:

* libcapstone (for the OPcache `--with-capstone` option)
* libssl (for OpenSSL `--with-openssl`)
* libkrb5 (for the OpenSSL `--with-kerberos` option)
* libaspell and libpspell (for the ext/pspell `--with-pspell` option)
* zlib
  * when using `--enable-gd` with bundled libgd
  * when using `--with-zlib`
  * when using `--with-pdo-mysql` or `--with-mysqli` (option
    `--enable-mysqlnd-compression-support` needs it)
* libpng
  * when using `--enable-gd` with bundled libgd
* libavif
  * when using `--enable-gd` with bundled libgd and `--with-avif` option.
* libwebp
  * when using `--enable-gd` with bundled libgd and `--with-webp` option.
* libjpeg
  * when using `--enable-gd` with bundled libgd and `--with-jpeg` option.
* libxpm
  * when using `--enable-gd` with bundled libgd and `--with-xpm` option.
* libfretype
  * when using `--enable-gd` with bundled libgd and `--with-freetype` option.
* libgd
  * when using `--enable-gd` with external libgd `--with-external-gd`.
* libonig
  * when using `--enable-mbstring`
* libtidy
  * when using `--with-tidy`
* libxslt
  * when using `--with-xsl`
* libzip
  * when using `--with-zip`
* libargon2
  * when using `--with-password-argon2`
* libedit
  * when using `--with-libedit`
* libreadline
  * when using `--with-readline`
* libsnmp
  * when using `--with-snmp`
* libexpat1
  * when using the `--with-expat`
* libacl
  * when using the `--with-fpm-acl`
* libapparmor
  * when using the `--with-fpm-apparmor`
* libselinux1
  * when using the `--with-fpm-selinux`
* libsystemd
  * when using the `--with-fpm-systemd`
* libldap2
  * when using the `--with-ldap`
* libsasl2
  * when using the `--with-ldap-sasl`
* libpq
  * when using the `--with-pgsql` or `--with-pdo-pgsql`
* libmm
  * when using the `--with-mm`
* libdmalloc
  * when using the `--enable-dmalloc`
* freetds
  * when using the `--enable-pdo-dblib`
* libcdb
  * when using the `--with-cdb=DIR`
* liblmdb
  * when using the `--with-lmdb`
* libtokyocabinet
  * when using the `--with-tcadb`
* libgdbm
  * when using the `--with-gdbm`
* libqdbm
  * when using the `--with-qdbm`
* libgdbm or library implementing the ndbm or dbm compatibility interface
  * when using the `--with-dbm` or `--with-ndbm`
* libdb
  * when using the `--with-db4`, `--with-db3`, `--with-db2`, or `--with-db1`

When PHP is built, the development libraries are no longer required to be
installed and only libraries without development files are needed to run newly
built PHP. In example of `ext/zip` extension, the `libzip` package is needed and
so on.

### 6.3. The configure command-line options

With Autoconf, there are two main types of command-line options for the
`configure` script (`--enable-FEATURE` and `--with-PACKAGE`):

* `--enable-FEATURE[=ARG]` and its belonging opposite `--disable-FEATURE`

  `--disable-FEATURE` is the same as `--enable-FEATURE=no`

  These normally don't require 3rd party library or package installed on the
  system. For some extensions, PHP bundles 3rd party dependencies in the
  extension itself. For example, `bcmath`, `gd`, etc.

* `--with-PACKAGE[=ARG]` and its belonging opposite `--without-PACKAGE`

  `--without-PACKAGE` is the same as `--with-PACKAGE=no`

  These require 3rd party package installed on the system. PHP has even some
  libraries bundled in PHP source code. For example, the PCRE library and
  similar.

Others custom options that don't follow this pattern are used for adjusting
specific features during built process.

See `./configure --help` for more info.

This wraps up the \*nix build system using the Autotools.

## 7. CMake

[CMake](https://cmake.org/) is an open-source cross-platform build system
generator created by Kitware and contributors.

### 7.1. Why using CMake?

CMake is today more actively developed and more developers might be familiar
with it. It also makes C code more attractive to new contributors. Many IDEs
provide a good CMake integration for C/C++ projects.

Many things are very similar to Autoconf, which makes maintaining multiple build
systems simpler.

CMake also has a better out of the box support in Windows systems, where
Autotools can run into issues without further adaptations and adjustments in the
build process.

Even though Autotools might be complex and arcane to new developers not
famililar with it, it can still be a very robust and solid build system option
in C/C++ projects on \*nix systems. Many large open-source projects use
Autotools. Some even use it together with CMake.

### 7.2. Directory structure

Directory structure from the CMake perspective looks like this:

```sh
<php-src>/
 └─ cmake/                   # CMake-based PHP build system files
    └─ modules/              # Project specific CMake modules
       └─ PHP/               # PHP utility modules namespace directory
          ├─ */              # Optional module directories with additional files
          └─ *.cmake         # Project customized CMake utility modules
       └─ Zend/              # Zend utility modules namespace directory
          └─ ...
       ├─ Find*.cmake        # Find modules that support the find_package()
       └─ *.cmake            # Any possible additional utility modules
    ├─ *.cmake               # Various CMake configurations and tools
    ├─ cmake-format.json     # cmake-lint and cmake-format tools configuration
    └─ ...
 └─ ext/
    └─ date/
       ├─ CMakeLists.txt     # Extension's CMake file
       └─ ...
    └─ ...
 └─ main/
    ├─ php_config.cmake.h.in # Configuration header template
    ├─ php_version.h         # Generated by release managers using `configure`
    ├─ CMakeLists.txt        # CMake file for main binding
    └─ ...
 └─ pear/
    ├─ CMakeLists.txt        # CMake file for PEAR
    └─ ...
 └─ sapi/
    └─ cli/
       ├─ CMakeLists.txt     # CMake file for SAPI module
       └─ ...
    └─ ...
 ├─ scripts/
 └─ TSRM/
    ├─ CMakeLists.txt        # CMake file for thread safe resource manager
    └─ ...
 └─ Zend/
    ├─ CMakeLists.txt        # Zend engine CMake file
    └─ ...
 ├─ CMakeLists.txt           # Root CMake file
 ├─ CMakePresets.json        # Main CMake presets file
 └─ ...
```

### 7.3. CMake-based PHP build system diagram

![CMake-based PHP build system](docs/images/cmake.svg)

### 7.4. CMake usage

```sh
cmake .
cmake --build .
```

### 7.5. CMake minimum version for PHP

The minimum required version of CMake is defined in the top project file
`CMakeLists.txt` using the `cmake_minimum_required()`. Picking the minimum
required CMake version is a compromise between CMake functionalities and CMake
version available on the operating system.

* 3.17
  * `CMAKE_CURRENT_FUNCTION_LIST_DIR` variable
* 3.19
  * `CMakePresets.json` for sharing build configurations
* 3.20
  * `CMAKE_C_BYTE_ORDER`, otherwise manual check should be done
  * `"version": 2` in `CMakePresets.json`
  * `Intl::Intl` IMPORTED target with CMake's FindIntl module
* 3.21
  * `"version": 3` in `CMakePresets.json` (for the `installDir` option)
* 3.22
  * Full condition syntax in `cmake_dependent_option()`
* 3.23
  * `target_sources(FILE_SET)`, otherwise `install(FILES)` should be used when
    installing files to their destinations
* 3.24
  * `CMAKE_COMPILE_WARNING_AS_ERROR`, otherwise INTERFACE library should be used
* 3.25
  * `block()` command
  * New `try_run` signature

Currently, the CMake minimum version is set to **3.25** without looking at CMake
available version on the current systems out there. This will be updated more
properly in the future.

CMake versions scheme across the systems is available at
[pkgs.org](https://pkgs.org/download/cmake).

### 7.6. Command-line options

List of configure command-line options and their CMake alternatives.

These can be passed like this:

```sh
# With Autotools:
./configure --enable-FEATURE --with-PACKAGE

# With CMake at the configuration phase:
cmake -DEXT_NAME=ON -DPHP_OPTION ../php-src
```

To see all configuration options and variables:

```sh
# With Autotools:
./buildconf
./configure --help

# CMake needs to first configure cache and then cache variables can be listed
# with help texts using the -LH option. Another option is to use cmake-gui tool.
cmake -LH .
```

<table>
  <thead>
    <tr>
      <th>configure</th>
      <th>CMake</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>--disable-re2c-cgoto</td>
      <td>PHP_RE2C_CGOTO=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-re2c-cgoto</td>
      <td>&nbsp;&nbsp;PHP_RE2C_CGOTO=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-debug-assertions</td>
      <td>PHP_DEBUG_ASSERTIONS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-debug-assertions</td>
      <td>&nbsp;&nbsp;PHP_DEBUG_ASSERTIONS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sigchild</td>
      <td>PHP_SIGCHILD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sigchild</td>
      <td>&nbsp;&nbsp;PHP_SIGCHILD=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-debug</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-debug</td>
      <td>&nbsp;&nbsp;CMAKE_BUILD_TYPE=Debug (single-configuration builds) or CMAKE_CONFIGURATION_TYPES=Debug (multi-configuration builds)</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-ipv6</td>
      <td>PHP_IPV6=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-ipv6</td>
      <td>&nbsp;&nbsp;PHP_IPV6=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-rtld-now</td>
      <td>PHP_USE_RTLD_NOW=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-rtld-now</td>
      <td>&nbsp;&nbsp;PHP_USE_RTLD_NOW=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-short-tags</td>
      <td>PHP_SHORT_TAGS=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-short-tags</td>
      <td>&nbsp;&nbsp;PHP_SHORT_TAGS=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zts</td>
      <td>PHP_THREAD_SAFETY=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-zts</td>
      <td>&nbsp;&nbsp;PHP_THREAD_SAFETY=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dtrace</td>
      <td>PHP_DTRACE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dtrace</td>
      <td>&nbsp;&nbsp;PHP_DTRACE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fd-setsize</td>
      <td>PHP_FD_SETSIZE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-fd-setsize=[NUM]</td>
      <td>&nbsp;&nbsp;PHP_FD_SETSIZE=[NUM]</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-valgrind</td>
      <td>PHP_VALGRIND=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-valgrind</td>
      <td>&nbsp;&nbsp;PHP_VALGRIND=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-libdir=[NAME]</td>
      <td>CMAKE_INSTALL_LIBDIR=[NAME]</td>
      <td>See GNUInstallDirs</td>
    </tr>
    <tr>
      <td>--with-layout=PHP|GNU</td>
      <td>PHP_LAYOUT=PHP|GNU</td>
      <td>default: PHP</td>
    </tr>
    <tr>
      <td>--disable-werror</td>
      <td>PHP_WERROR=OFF or --compile-no-warning-as-error</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-werror</td>
      <td>&nbsp;&nbsp;PHP_WERROR=ON or CMAKE_COMPILE_WARNING_AS_ERROR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-memory-sanitizer</td>
      <td>PHP_MEMORY_SANITIZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-memory-sanitizer</td>
      <td>&nbsp;&nbsp;PHP_MEMORY_SANITIZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-address-sanitizer</td>
      <td>PHP_ADDRESS_SANITIZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-address-sanitizer</td>
      <td>&nbsp;&nbsp;PHP_ADDRESS_SANITIZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-undefined-sanitizer</td>
      <td>PHP_UNDEFINED_SANITIZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-undefined-sanitizer</td>
      <td>&nbsp;&nbsp;PHP_UNDEFINED_SANITIZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dmalloc</td>
      <td>PHP_DMALLOC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dmalloc</td>
      <td>&nbsp;&nbsp;PHP_DMALLOC=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-config-file-scan-dir</td>
      <td>PHP_CONFIG_FILE_SCAN_DIR=""</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-config-file-scan-dir=DIR</td>
      <td>&nbsp;&nbsp;PHP_CONFIG_FILE_SCAN_DIR=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-config-file-path</td>
      <td>PHP_CONFIG_FILE_PATH=""</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-config-file-path=PATH</td>
      <td>&nbsp;&nbsp;PHP_CONFIG_FILE_PATH=PATH</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>Zend specific configuration</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-gcc-global-regs</td>
      <td>ZEND_GCC_GLOBAL_REGS=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-gcc-global-regs</td>
      <td>&nbsp;&nbsp;ZEND_GCC_GLOBAL_REGS=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fiber-asm</td>
      <td>ZEND_FIBER_ASM=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-fiber-asm</td>
      <td>&nbsp;&nbsp;ZEND_FIBER_ASM=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-zend-signals</td>
      <td>ZEND_SIGNALS=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-zend-signals</td>
      <td>&nbsp;&nbsp;ZEND_SIGNALS=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zend-max-execution-timers</td>
      <td>ZEND_MAX_EXECUTION_TIMERS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-zend-max-execution-timers</td>
      <td>&nbsp;&nbsp;ZEND_MAX_EXECUTION_TIMERS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>PHP SAPI modules</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--without-apxs2</td>
      <td>SAPI_APACHE2HANDLER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-apxs2[=FILE]</td>
      <td>&nbsp;&nbsp;SAPI_APACHE2HANDLER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-cgi</td>
      <td>SAPI_CGI=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-cgi</td>
      <td>&nbsp;&nbsp;SAPI_CGI=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-cli</td>
      <td>CAPI_CLI=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-cli</td>
      <td>&nbsp;&nbsp;SAPI_CLI=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-embed</td>
      <td>SAPI_EMBED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-embed</td>
      <td>&nbsp;&nbsp;SAPI_EMBED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fpm</td>
      <td>SAPI_FPM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-fpm</td>
      <td>&nbsp;&nbsp;SAPI_FPM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-fpm-user[=USER]</td>
      <td>&nbsp;&nbsp;SAPI_FPM_USER=nobody</td>
      <td>default: nobody</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-fpm-group[=GROUP]</td>
      <td>&nbsp;&nbsp;SAPI_FPM_GROUP=nobody</td>
      <td>default: nobody</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-fpm-systemd</td>
      <td>&nbsp;&nbsp;SAPI_FPM_SYSTEMD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-fpm-systemd</td>
      <td>&nbsp;&nbsp;SAPI_FPM_SYSTEMD=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-fpm-acl</td>
      <td>&nbsp;&nbsp;SAPI_FPM_ACL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-fpm-acl</td>
      <td>&nbsp;&nbsp;SAPI_FPM_ACL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-fpm-apparmor</td>
      <td>&nbsp;&nbsp;SAPI_FPM_APPARMOR=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-fpm-apparmor</td>
      <td>&nbsp;&nbsp;SAPI_FPM_APPARMOR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-fpm-selinux</td>
      <td>&nbsp;&nbsp;SAPI_FPM_SELINUX=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-fpm-selinux</td>
      <td>&nbsp;&nbsp;SAPI_FPM_SELINUX=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fuzzer</td>
      <td>SAPI_FUZZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-fuzzer</td>
      <td>&nbsp;&nbsp;SAPI_FUZZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-litespeed</td>
      <td>SAPI_LITESPEED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-litespeed</td>
      <td>&nbsp;&nbsp;SAPI_LITESPEED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-phpdbg</td>
      <td>SAPI_PHPDBG=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-phpdbg</td>
      <td>&nbsp;&nbsp;SAPI_PHPDBG=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-phpdbg-debug</td>
      <td>&nbsp;&nbsp;SAPI_PHPDBG_DEBUG=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-phpdbg-debug</td>
      <td>&nbsp;&nbsp;SAPI_PHPDBG_DEBUG=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-phpdbg-readline</td>
      <td>&nbsp;&nbsp;SAPI_PHPDBG_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-phpdbg-readline</td>
      <td>&nbsp;&nbsp;SAPI_PHPDBG_READLINE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>PHP extensions</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-bcmath</td>
      <td>EXT_BCMATH=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-bcmath</td>
      <td>&nbsp;&nbsp;EXT_BCMATH=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-bcmath=shared</td>
      <td>&nbsp;&nbsp;EXT_BCMATH_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-bz2</td>
      <td>EXT_BZ2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-bz2</td>
      <td>&nbsp;&nbsp;EXT_BZ2=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-bz2=shared</td>
      <td>&nbsp;&nbsp;EXT_BZ2_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-bz2=DIR</td>
      <td>&nbsp;&nbsp;BZip2_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-calendar</td>
      <td>EXT_CALENDAR=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-calendar</td>
      <td>&nbsp;&nbsp;EXT_CALENDAR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-calendar=shared</td>
      <td>&nbsp;&nbsp;EXT_CALENDAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-ctype</td>
      <td>EXT_CTYPE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-ctype=shared</td>
      <td>&nbsp;&nbsp;EXT_CTYPE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-ctype</td>
      <td>&nbsp;&nbsp;EXT_CTYPE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-curl</td>
      <td>EXT_CURL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-curl</td>
      <td>&nbsp;&nbsp;EXT_CURL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-curl=shared</td>
      <td>&nbsp;&nbsp;EXT_CURL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dba</td>
      <td>EXT_DBA=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dba</td>
      <td>&nbsp;&nbsp;EXT_DBA=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dba=shared</td>
      <td>&nbsp;&nbsp;EXT_DBA_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-flatfile</td>
      <td>&nbsp;&nbsp;EXT_DBA_FLATFILE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-flatfile</td>
      <td>&nbsp;&nbsp;EXT_DBA_FLATFILE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-inifile</td>
      <td>&nbsp;&nbsp;EXT_DBA_INIFILE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-inifile</td>
      <td>&nbsp;&nbsp;EXT_DBA_INIFILE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-qdbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_QDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-qdbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_QDBM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-qdbm=DIR</td>
      <td>&nbsp;&nbsp;QDBM_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-gdbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_GDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gdbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_GDBM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gdbm=DIR</td>
      <td>&nbsp;&nbsp;GDBM_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-ndbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_NDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ndbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_NDBM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-db4</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-db4</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-db4=DIR</td>
      <td>&nbsp;&nbsp;BerkeleyDB_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-db3</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB3=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-db3</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB3=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-db2</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-db2</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB2=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-db1</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB_1=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-db1</td>
      <td>&nbsp;&nbsp;EXT_DBA_DB_1=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-dbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_DBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-dbm</td>
      <td>&nbsp;&nbsp;EXT_DBA_DBM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-tcadb</td>
      <td>&nbsp;&nbsp;EXT_DBA_TCADB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-tcadb</td>
      <td>&nbsp;&nbsp;EXT_DBA_TCADB=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-tcadb=DIR</td>
      <td>&nbsp;&nbsp;TokyoCabinet_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-lmdb</td>
      <td>&nbsp;&nbsp;EXT_DBA_LMDB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-lmdb</td>
      <td>&nbsp;&nbsp;EXT_DBA_LMDB=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-lmdb=DIR</td>
      <td>&nbsp;&nbsp;LMDB_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-cdb</td>
      <td>&nbsp;&nbsp;EXT_DBA_CDB=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-cdb=DIR</td>
      <td>&nbsp;&nbsp;EXT_DBA_CDB_EXTERNAL=ON (Cdb_ROOT=DIR to customize)</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-cdb</td>
      <td>&nbsp;&nbsp;EXT_DBA_CDB=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dl-test</td>
      <td>EXT_DL_TEST=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dl-test</td>
      <td>&nbsp;&nbsp;EXT_DL_TEST=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dl-test=shared</td>
      <td>&nbsp;&nbsp;EXT_DL_TEST=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>--enable-dom</td>
      <td>EXT_DOM=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-dom=shared</td>
      <td>&nbsp;&nbsp;EXT_DOM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-dom</td>
      <td>&nbsp;&nbsp;EXT_DOM=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-enchant</td>
      <td>EXT_ENCHANT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-enchant</td>
      <td>&nbsp;&nbsp;EXT_ENCHANT=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-enchant=shared</td>
      <td>&nbsp;&nbsp;EXT_ENCHANT_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-exif</td>
      <td>EXT_EXIF=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-exif</td>
      <td>&nbsp;&nbsp;EXT_EXIF=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-exif=shared</td>
      <td>&nbsp;&nbsp;EXT_EXIF_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-ffi</td>
      <td>EXT_FFI=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ffi</td>
      <td>&nbsp;&nbsp;EXT_FFI=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ffi=shared</td>
      <td>&nbsp;&nbsp;EXT_FFI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fileinfo</td>
      <td>EXT_FILEINFO=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-fileinfo=shared</td>
      <td>&nbsp;&nbsp;EXT_FILEINFO_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-fileinfo</td>
      <td>&nbsp;&nbsp;EXT_FILEINFO=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-filter</td>
      <td>EXT_FILTER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-filter=shared</td>
      <td>&nbsp;&nbsp;EXT_FILTER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-filter</td>
      <td>&nbsp;&nbsp;EXT_FILTER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-ftp</td>
      <td>EXT_FTP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-ftp</td>
      <td>&nbsp;&nbsp;EXT_FTP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-ftp=shared</td>
      <td>&nbsp;&nbsp;EXT_FTP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-openssl-dir</td>
      <td>&nbsp;&nbsp;EXT_FTP_SSL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-openssl-dir</td>
      <td>&nbsp;&nbsp;EXT_FTP_SSL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-gd</td>
      <td>EXT_GD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-gd</td>
      <td>&nbsp;&nbsp;EXT_GD=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-gd=shared</td>
      <td>&nbsp;&nbsp;EXT_GD_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-external-gd</td>
      <td>&nbsp;&nbsp;EXT_GD_EXTERNAL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-external-gd</td>
      <td>&nbsp;&nbsp;EXT_GD_EXTERNAL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-avif</td>
      <td>&nbsp;&nbsp;EXT_GD_AVIF=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-avif</td>
      <td>&nbsp;&nbsp;EXT_GD_AVIF=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-webp</td>
      <td>&nbsp;&nbsp;EXT_GD_WEBP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-webp</td>
      <td>&nbsp;&nbsp;EXT_GD_WEBP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-jpeg</td>
      <td>&nbsp;&nbsp;EXT_GD_JPEG=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-jpeg</td>
      <td>&nbsp;&nbsp;EXT_GD_JPEG=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-xpm</td>
      <td>&nbsp;&nbsp;EXT_GD_XPM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-xpm</td>
      <td>&nbsp;&nbsp;EXT_GD_XPM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-freetype</td>
      <td>&nbsp;&nbsp;EXT_GD_FREETYPE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-freetype</td>
      <td>&nbsp;&nbsp;EXT_GD_FREETYPE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-gd-jis-conv</td>
      <td>&nbsp;&nbsp;EXT_GD_JIS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-gd-jis-conv</td>
      <td>&nbsp;&nbsp;EXT_GD_JIS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-gettext</td>
      <td>EXT_GETTEXT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gettext</td>
      <td>&nbsp;&nbsp;EXT_GETTEXT=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gettext=shared</td>
      <td>&nbsp;&nbsp;EXT_GETTEXT_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gettext=DIR</td>
      <td>&nbsp;&nbsp;EXT_GETTEXT=ON Intl_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-gmp</td>
      <td>EXT_GMP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gmp[=DIR]</td>
      <td>&nbsp;&nbsp;EXT_GMP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-gmp=shared</td>
      <td>&nbsp;&nbsp;EXT_GMP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mhash</td>
      <td>EXT_HASH_MHASH=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mhash</td>
      <td>&nbsp;&nbsp;EXT_HASH_MHASH=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-iconv</td>
      <td>EXT_ICONV=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-iconv=shared</td>
      <td>&nbsp;&nbsp;EXT_ICONV_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-iconv</td>
      <td>&nbsp;&nbsp;EXT_ICONV=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-intl</td>
      <td>EXT_INTL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-intl</td>
      <td>&nbsp;&nbsp;EXT_INTL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-intl=shared</td>
      <td>&nbsp;&nbsp;EXT_INTL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-intl ICU_CFLAGS=... ICU_LIBS=...</td>
      <td>&nbsp;&nbsp;EXT_INTL=ON ICU_ROOT=...</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-ldap</td>
      <td>EXT_LDAP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ldap</td>
      <td>&nbsp;&nbsp;EXT_LDAP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ldap=shared</td>
      <td>&nbsp;&nbsp;EXT_LDAP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-ldap-sasl</td>
      <td>&nbsp;&nbsp;EXT_LDAP_SASL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ldap-sasl</td>
      <td>&nbsp;&nbsp;EXT_LDAP_SASL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-libxml</td>
      <td>EXT_LIBXML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-libxml</td>
      <td>&nbsp;&nbsp;EXT_LIBXML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-mbstring</td>
      <td>EXT_MBSTRING=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-mbstring</td>
      <td>&nbsp;&nbsp;EXT_MBSTRING=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-mbstring=shared</td>
      <td>&nbsp;&nbsp;EXT_MBSTRING_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-mbregex</td>
      <td>&nbsp;&nbsp;EXT_MBSTRING_MBREGEX=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-mbregex</td>
      <td>&nbsp;&nbsp;EXT_MBSTRING_MBREGEX=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysqli</td>
      <td>EXT_MYSQLI=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mysqli</td>
      <td>&nbsp;&nbsp;EXT_MYSQLI=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mysqli=shared</td>
      <td>&nbsp;&nbsp;EXT_MYSQLI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysql-sock</td>
      <td>EXT_MYSQL_SOCK=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mysql-sock</td>
      <td>&nbsp;&nbsp;EXT_MYSQL_SOCK=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mysql-sock=SOCKET</td>
      <td>&nbsp;&nbsp;EXT_MYSQL_SOCK=ON EXT_MYSQL_SOCK_PATH=/path/to/mysql.sock</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-mysqlnd</td>
      <td>EXT_MYSQLND=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-mysqlnd</td>
      <td>&nbsp;&nbsp;EXT_MYSQLND=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-mysqlnd=shared</td>
      <td>&nbsp;&nbsp;EXT_MYSQLND_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-mysqlnd-compression-support</td>
      <td>&nbsp;&nbsp;EXT_MYSQLND_COMPRESSION=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-mysqlnd-compression-support</td>
      <td>&nbsp;&nbsp;EXT_MYSQLND_COMPRESSION=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>&nbsp;&nbsp;EXT_MYSQLND_SSL=OFF</td>
      <td>default, see also --with-openssl-dir and EXT_FTP_SSL</td>
    </tr>
    <tr>
      <td></td>
      <td>&nbsp;&nbsp;EXT_MYSQLND_SSL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-opcache=shared</td>
      <td>EXT_OPCACHE=ON</td>
      <td>default, will be shared</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-opcache</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-opcache</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-huge-code-pages</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE_HUGE_CODE_PAGES=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-huge-code-pages</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE_HUGE_CODE_PAGES=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-opcache-jit</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE_JIT=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-opcache-jit</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE_JIT=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-capstone</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE_CAPSTONE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-capstone</td>
      <td>&nbsp;&nbsp;EXT_OPCACHE_CAPSTONE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-openssl</td>
      <td>EXT_OPENSSL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-openssl</td>
      <td>&nbsp;&nbsp;EXT_OPENSSL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-openssl=shared</td>
      <td>&nbsp;&nbsp;EXT_OPENSSL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-kerberos</td>
      <td>&nbsp;&nbsp;EXT_OPENSSL_KERBEROS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-kerberos</td>
      <td>&nbsp;&nbsp;EXT_OPENSSL_KERBEROS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-system-ciphers</td>
      <td>&nbsp;&nbsp;EXT_OPENSSL_SYSTEM_CIPHERS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-system-ciphers</td>
      <td>&nbsp;&nbsp;EXT_OPENSSL_SYSTEM_CIPHERS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-pcntl</td>
      <td>EXT_PCNTL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-pcntl</td>
      <td>&nbsp;&nbsp;EXT_PCNTL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-pcntl=shared</td>
      <td>&nbsp;&nbsp;EXT_PCNTL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-external-pcre</td>
      <td>EXT_PCRE_EXTERNAL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-external-pcre</td>
      <td>&nbsp;&nbsp;EXT_PCRE_EXTERNAL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pcre-jit</td>
      <td>&nbsp;&nbsp;EXT_PCRE_JIT=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pcre-jit</td>
      <td>&nbsp;&nbsp;EXT_PCRE_JIT=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-external-pcre PCRE2_CFLAGS=... PCRE2_LIBS=...</td>
      <td>&nbsp;&nbsp;EXT_PCRE_EXTERNAL=ON PCRE_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-pdo</td>
      <td>EXT_PDO=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-pdo=shared</td>
      <td>&nbsp;&nbsp;EXT_PDO_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-pdo</td>
      <td>&nbsp;&nbsp;EXT_PDO=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-dblib</td>
      <td>&nbsp;&nbsp;EXT_PDO_DBLIB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-dblib</td>
      <td>&nbsp;&nbsp;EXT_PDO_DBLIB=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-dblib=shared</td>
      <td>&nbsp;&nbsp;EXT_PDO_DBLIB_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-dblib=DIR</td>
      <td>&nbsp;&nbsp;FreeTDS_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-firebird</td>
      <td>&nbsp;&nbsp;EXT_PDO_FIREBIRD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-firebird</td>
      <td>&nbsp;&nbsp;EXT_PDO_FIREBIRD=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-firebird=shared</td>
      <td>&nbsp;&nbsp;EXT_PDO_FIREBIRD_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-firebird=DIR</td>
      <td>&nbsp;&nbsp;Firebird_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-mysql</td>
      <td>&nbsp;&nbsp;EXT_PDO_MYSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql</td>
      <td>&nbsp;&nbsp;EXT_PDO_MYSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql=shared</td>
      <td>&nbsp;&nbsp;EXT_PDO_MYSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-pgsql</td>
      <td>&nbsp;&nbsp;EXT_PDO_PGSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-pgsql</td>
      <td>&nbsp;&nbsp;EXT_PDO_PGSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-pgsql=shared</td>
      <td>&nbsp;&nbsp;EXT_PDO_PGSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-pgsql=DIR</td>
      <td>&nbsp;&nbsp;PostgreSQL_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-sqlite</td>
      <td>&nbsp;&nbsp;EXT_PDO_SQLITE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-sqlite=shared</td>
      <td>&nbsp;&nbsp;EXT_PDO_SQLITE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-sqlite</td>
      <td>&nbsp;&nbsp;EXT_PDO_SQLITE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-pgsql</td>
      <td>EXT_PGSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pgsql</td>
      <td>&nbsp;&nbsp;EXT_PGSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pgsql=shared</td>
      <td>&nbsp;&nbsp;EXT_PGSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pgsql=DIR</td>
      <td>&nbsp;&nbsp;PostgreSQL_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-phar</td>
      <td>EXT_PHAR=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-phar=shared</td>
      <td>&nbsp;&nbsp;EXT_PHAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-phar</td>
      <td>&nbsp;&nbsp;EXT_PHAR=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-posix</td>
      <td>EXT_POSIX=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-posix=shared</td>
      <td>&nbsp;&nbsp;EXT_POSIX_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-posix</td>
      <td>&nbsp;&nbsp;EXT_POSIX=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-pspell</td>
      <td>EXT_PSPELL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pspell</td>
      <td>&nbsp;&nbsp;EXT_PSPELL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pspell=shared</td>
      <td>&nbsp;&nbsp;EXT_PSPELL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-libedit</td>
      <td>EXT_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-libedit</td>
      <td>&nbsp;&nbsp;EXT_READLINE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-libedit EDIT_CFLAGS=... EDIT_LIBS=...</td>
      <td>&nbsp;&nbsp;EXT_READLINE=ON Editline_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-libedit=shared</td>
      <td>&nbsp;&nbsp;EXT_READLINE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-readline</td>
      <td>&nbsp;&nbsp;EXT_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-readline</td>
      <td>&nbsp;&nbsp;EXT_READLINE=ON EXT_READLINE_LIBREADLINE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-readline=shared</td>
      <td>&nbsp;&nbsp;EXT_READLINE=ON EXT_READLINE_SHARED=ON EXT_READLINE_LIBREADLINE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-readline=DIR</td>
      <td>&nbsp;&nbsp;EXT_READLINE=ON EXT_READLINE_LIBREADLINE=ON Readline_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-session</td>
      <td>EXT_SESSION=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-session=shared</td>
      <td>&nbsp;&nbsp;EXT_SESSION_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-session</td>
      <td>&nbsp;&nbsp;EXT_SESSION=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-mm</td>
      <td>&nbsp;&nbsp;EXT_SESSION_MM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mm</td>
      <td>&nbsp;&nbsp;EXT_SESSION_MM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-mm=DIR</td>
      <td>&nbsp;&nbsp;MM_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-shmop</td>
      <td>EXT_SHMOP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-shmop</td>
      <td>&nbsp;&nbsp;EXT_SHMOP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-shmop=shared</td>
      <td>&nbsp;&nbsp;EXT_SHMOP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-simplexml</td>
      <td>EXT_SIMPLEXML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-simplexml=shared</td>
      <td>&nbsp;&nbsp;EXT_SIMPLEXML_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-simplexml</td>
      <td>&nbsp;&nbsp;EXT_SIMPLEXML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-snmp</td>
      <td>EXT_SNMP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-snmp</td>
      <td>&nbsp;&nbsp;EXT_SNMP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-snmp=shared</td>
      <td>&nbsp;&nbsp;EXT_SNMP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-snmp=DIR</td>
      <td>&nbsp;&nbsp;NetSnmp_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-soap</td>
      <td>EXT_SOAP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-soap</td>
      <td>&nbsp;&nbsp;EXT_SOAP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-soap=shared</td>
      <td>&nbsp;&nbsp;EXT_SOAP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sockets</td>
      <td>EXT_SOCKETS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sockets</td>
      <td>&nbsp;&nbsp;EXT_SOCKETS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sockets=shared</td>
      <td>&nbsp;&nbsp;EXT_SOCKETS_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-sodium</td>
      <td>EXT_SODIUM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-sodium</td>
      <td>&nbsp;&nbsp;EXT_SODIUM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-sodium=shared</td>
      <td>&nbsp;&nbsp;EXT_SODIUM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-sqlite3</td>
      <td>EXT_SQLITE3=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-sqlite3=shared</td>
      <td>&nbsp;&nbsp;EXT_SQLITE3_SHARED</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-sqlite3</td>
      <td>&nbsp;&nbsp;EXT_SQLITE3=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-external-libcrypt</td>
      <td>EXT_STANDARD_EXTERNAL_LIBCRYPT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-external-libcrypt</td>
      <td>&nbsp;&nbsp;EXT_STANDARD_EXTERNAL_LIBCRYPT=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-password-argon2</td>
      <td>&nbsp;&nbsp;EXT_STANDARD_ARGON2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-password-argon2</td>
      <td>&nbsp;&nbsp;EXT_STANDARD_ARGON2=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sysvmsg</td>
      <td>EXT_SYSVMSG=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sysvmsg</td>
      <td>&nbsp;&nbsp;EXT_SYSVMSG=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sysvmsg=shared</td>
      <td>&nbsp;&nbsp;EXT_SYSVMSG_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sysvsem</td>
      <td>EXT_SYSVSEM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sysvsem</td>
      <td>&nbsp;&nbsp;EXT_SYSVSEM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sysvsem=shared</td>
      <td>&nbsp;&nbsp;EXT_SYSVSEM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sysvshm</td>
      <td>EXT_SYSVSHM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sysvshm</td>
      <td>&nbsp;&nbsp;EXT_SYSVSHM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-sysvshm=shared</td>
      <td>&nbsp;&nbsp;EXT_SYSVSHM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-tidy</td>
      <td>EXT_TIDY=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-tidy</td>
      <td>&nbsp;&nbsp;EXT_TIDY=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-tidy=DIR</td>
      <td>&nbsp;&nbsp;Tidy_ROOT=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-tidy=shared</td>
      <td>&nbsp;&nbsp;EXT_TIDY_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-tokenizer</td>
      <td>EXT_TOKENIZER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-tokenizer=shared</td>
      <td>&nbsp;&nbsp;EXT_TOKENIZER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-tokenizer</td>
      <td>&nbsp;&nbsp;EXT_TOKENIZER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xml</td>
      <td>EXT_XML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-xml=shared</td>
      <td>&nbsp;&nbsp;EXT_XML_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-xml</td>
      <td>&nbsp;&nbsp;EXT_XML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-expat</td>
      <td>&nbsp;&nbsp;EXT_XML_EXPAT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-expat</td>
      <td>&nbsp;&nbsp;EXT_XML_EXPAT=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-xsl</td>
      <td>EXT_XSL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-xsl</td>
      <td>&nbsp;&nbsp;EXT_XSL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-xsl=shared</td>
      <td>&nbsp;&nbsp;EXT_XSL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xmlreader</td>
      <td>EXT_XMLREADER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-xmlreader=shared</td>
      <td>&nbsp;&nbsp;EXT_XMLREADER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-xmlreader</td>
      <td>&nbsp;&nbsp;EXT_XMLREADER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xmlwriter</td>
      <td>EXT_XMLWRITER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-xmlwriter=shared</td>
      <td>&nbsp;&nbsp;EXT_XMLWRITER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-xmlwriter</td>
      <td>&nbsp;&nbsp;EXT_XMLWRITER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zend-test</td>
      <td>EXT_ZEND_TEST=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-zend-test</td>
      <td>&nbsp;&nbsp;EXT_ZEND_TEST=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--enable-zend-test=shared</td>
      <td>&nbsp;&nbsp;EXT_ZEND_TEST_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-zip</td>
      <td>EXT_ZIP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-zip</td>
      <td>&nbsp;&nbsp;EXT_ZIP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-zip=shared</td>
      <td>&nbsp;&nbsp;EXT_ZIP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-zlib</td>
      <td>EXT_ZLIB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-zlib</td>
      <td>&nbsp;&nbsp;EXT_ZLIB=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-zlib=shared</td>
      <td>&nbsp;&nbsp;EXT_ZLIB_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>PEAR specific configuration</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pear</td>
      <td>&nbsp;&nbsp;PHP_PEAR=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pear</td>
      <td>&nbsp;&nbsp;PHP_PEAR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pear=DIR</td>
      <td>&nbsp;&nbsp;PHP_PEAR=ON PHP_PEAR_DIR=DIR</td>
      <td></td>
    </tr>
  </tbody>
</table>

List of configure environment variables:

These are passed like this:

```sh
# Autotools:
./configure VAR=VALUE

# CMake at the configuration phase:
cmake -DCMAKE_FOOVAR=ON -DPHP_VAR=... ../php-src
```

<table>
  <thead>
    <tr>
      <th>configure</th>
      <th>CMake</th>
      <th>Default value/notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>3rd party variables</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>LDFLAGS=&quot;...&quot;</td>
      <td>CMAKE_EXE_LINKER_FLAGS=&quot;...&quot;</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>CMAKE_SHARED_LINKER_FLAGS=&quot;...&quot;</td>
      <td></td>
    </tr>
    <tr>
      <td><strong>PHP variables</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>PHP_EXTRA_VERSION=&quot;-acme&quot;</td>
      <td>PHP_VERSION_LABEL=&quot;-acme&quot;</td>
      <td>-dev or empty</td>
    </tr>
    <tr>
      <td>PHP_UNAME=&quot;ACME Linux&quot;</td>
      <td>PHP_UNAME=&quot;ACME Linux&quot;</td>
      <td>uname -a ouput override</td>
    </tr>
    <tr>
      <td>PHP_BUILD_SYSTEM=&quot;ACME Linux&quot;</td>
      <td>PHP_BUILD_SYSTEM=&quot;ACME Linux&quot;</td>
      <td>uname -a ouput</td>
    </tr>
    <tr>
      <td>PHP_BUILD_PROVIDER=&quot;ACME&quot;</td>
      <td>PHP_BUILD_PROVIDER=&quot;ACME&quot;</td>
      <td>Additional build system info</td>
    </tr>
    <tr>
      <td>PHP_BUILD_COMPILER=&quot;ACME&quot;</td>
      <td>PHP_BUILD_COMPILER=&quot;ACME&quot;</td>
      <td>Additional build system info</td>
    </tr>
    <tr>
      <td>PHP_BUILD_ARCH=&quot;ACME&quot;</td>
      <td>PHP_BUILD_ARCH=&quot;ACME&quot;</td>
      <td>Additional build system info</td>
    </tr>
    <tr>
      <td>EXTENSION_DIR=&quot;path/to/ext&quot;</td>
      <td>PHP_EXTENSION_DIR=&quot;path/to/ext&quot;</td>
      <td>Override the INI extension_dir</td>
    </tr>
    <tr>
      <td><strong>Available only in CMake</strong></td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>BUILD_SHARED_LIBS=OFF|ON</td>
      <td>Build all enabled PHP extensions as shared libraries</td>
    </tr>
    <tr>
      <td></td>
      <td>CMAKE_MESSAGE_CONTEXT_SHOW=OFF|ON</td>
      <td>Show/hide context in configuration log ([ext/foo] Checking for...)</td>
    </tr>
    <tr>
      <td></td>
      <td>CMAKE_PREFIX_PATH=DIR_1;DIR_2;...</td>
      <td>A semicolon separated list of directories where packages can be found.
      Can be used as an alternative to above &lt;PackageName&gt;_ROOT variables.
      </td>
    </tr>
  </tbody>
</table>

When running `make VAR=VALUE` commands, the following environment variables are
available:

| make with PHP                   | CMake                             | Default value/notes            |
| ------------------------------- | --------------------------------- | ------------------------------ |
| `EXTRA_CFLAGS="..."`            |                                   | Append additional CFLAGS       |
| `EXTRA_LDFLAGS="..."`           |                                   | Append additional LDFLAGS      |
| `INSTALL_ROOT="..."`            | `CMAKE_INSTALL_PREFIX="..."`      | Override the installation dir  |
|                                 | or `cmake --install --prefix`     |                                |

### 7.7. CMake generators for building PHP

When using CMake to build PHP, you have the flexibility to choose from various
build systems through the concept of _generators_. CMake generators determine
the type of project files or build scripts that CMake generates from your
`CMakeLists.txt` file. In this example, we will check the following generators:
Unix Makefiles and Ninja.

#### 7.7.1. Unix Makefiles (default)

The Unix Makefiles generator is the most common and widely used generator for
building projects on Unix-like systems, including Linux and macOS. It generates
traditional `Makefile` that can be processed by the `make` command. To use the
Unix Makefiles generator, you simply specify it as an argument when running
CMake in your build directory.

To generate the `Makefile` for building PHP, create a new directory (often
called `build` or `cmake-build`) and navigate to it using the terminal. Then,
execute the following CMake command:

```sh
cmake -G "Unix Makefiles" /path/to/php-src
```

Replace `/path/to/php-src` with the actual path to the PHP source code on
your system (in case build directory is the same as the source directory, use
`.`). CMake will process the `CMakeLists.txt` file in the source directory and
generate the `Makefile` in the current build directory.

After the Makefiles are generated, you can use the make command to build PHP:

```sh
make
```

The make command will build the PHP binaries and libraries according to the
configuration specified in the `CMakeLists.txt` file. If you want to speed up
the build process, you can use the `-j` option to enable parallel builds, taking
advantage of multiple CPU cores:

```sh
make -j$(nproc) # number of CPU cores you want to utilize.
```

#### 7.7.2. Ninja

[Ninja](https://ninja-build.org/) is another build system supported by CMake and
is known for its fast build times due to its minimalistic design. To use the
Ninja generator, you need to have Ninja installed on your system. Most package
managers on Unix systems offer Ninja as a package, so you can install it easily.

To generate Ninja build files for building PHP, navigate to your build directory
in the terminal and run the following CMake command:

```sh
cmake -G "Ninja" /path/to/php-src
```

Again, replace `/path/to/php/src` with the actual path to the PHP source code.
CMake will generate the Ninja build files in the current directory.

To build PHP with Ninja, execute the following command:

```sh
ninja
```

Ninja will then handle the build process based on the CMake configuration.

### 7.8. CMake presets

The `CMakePresets.json` and `CMakeUserPresets.json` files in project root
directory are available since CMake 3.19 for sharing build configurations.

Instead of manually entering `cmake -DFOO=BAR ...` in command line, users can
simply store these configuration options in JSON file and have a shareable build
settings for continuous integration, development, bug reporting etc.

The [CMakePresets.json](/cmake/CMakePresets.json) example file includes some
common configuration and build settings.

To use the CMake presets:

```sh
# Configure project, replace "default" with the name of the "configurePresets".
cmake --preset default

# Build project using the "default" build preset.
cmake --build --preset default
```

File `CMakeUserPresets.json` is ignored in Git because it is intended for user
specific configuration.

### 7.9. CMake GUI

With CMake there comes also a basic graphical user interface to configure and
generate the build system.

Inside a CMake project, run:

```sh
cmake-gui .
```

![CMake GUI](docs/images/cmake-gui.png)

Here the build configuration can be done, such as enabling the PHP extensions,
adjusting the build options and similar.

CMake GUI makes it simpler to see available build options and settings and it
also conveniently hides and sets the dependent options. For example, if some PHP
extension provides multiple configuration options and it is disabled, the
dependent options won't be displayed after configuration.

![CMake GUI setup](docs/images/cmake-gui-2-setup.png)

After setting up, press the `Configure` button to start the configuration phase
and prepare the build configuration. The `Generate` buttons can then generate
the chosen build system.

![CMake GUI configuration](docs/images/cmake-gui-3.png)

GUI is only meant to configure and generate the build in user friendly way.
Building the sources to binaries can be then done in command line or IDE.

```sh
cmake --build --preset default
```

### 7.10. Command-line interface ccmake

The CMake curses interface (`ccmake`) is a command-line GUI, similar to the
CMake GUI, that simplifies the project configuration process in an intuitive and
straightforward manner.

```sh
# Run ccmake:
ccmake -S source-directory -B build-directory

# For in-source builds:
ccmake .
```

![The ccmake GUI](docs/images/ccmake.png)

* `c` key will run the configuration step
* `g` key will run the generation step (you might need to press `c` again)

Much like the CMake GUI, the build step is executed via the command line
afterward.

```sh
# Build the project sources from the specified build directory:
cmake --build build-directory -j
```

`ccmake` does not support presets but can be utilized for simpler configurations
during development and for similar workflows.

### 7.11. Testing

PHP source code tests (`*.phpt` files) are written in PHP and are executed with
`run-tests.php` script from the very beginning of the PHP development. When
building PHP with Autotools the tests are usually run by:

```sh
make TEST_PHP_ARGS=-j10 test
```

CMake ships with a `ctest` utility that can run also this in a similar way.

To enable testing the `enable_testing()` is added to the `CMakeLists.txt` file
and the tests are added with `add_test()`.

To run the tests using CMake in command line:

```sh
ctest --progress --verbose
```

The `--progress` option displays a progress if there's more tests set, and
`--verbose` option outputs additional info to the stdout. In PHP case the
`--verbose` is needed so the output of the `run-tests.php` script is displayed.

CMake testing also supports presets so configuration can be coded and shared
using the `CMakePresets.json` file and its `testPresets` field.

```sh
ctest --preset unix-full
```

### 7.12. Performance

When CMake is doing configuration phase, the profiling options can be used to do
build system performance analysis of CMake script.

```sh
cmake --profiling-output ./profile.json --profiling-format google-trace ../php-src
```

![CMake profiling](docs/images/cmake-profiling.png)

## 8. See more

Further help is documented at [docs](docs/README.md).

### 8.1. CMake and PHP

Existing CMake and PHP discussions and resources:

* [php-cmake](https://github.com/gloob/php-cmake) - CMake implementation in PHP.
* [CMake discussion on PHP mailing list](https://externals.io/message/116655)

### 8.2. PHP Internals

Useful resources to learn more about PHP internals:

* [PHP Internals Book](https://www.phpinternalsbook.com/)
