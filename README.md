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
# Prerequisites for Debian-based distributions:
sudo apt install cmake gcc g++ bison re2c libxml2-dev libsqlite3-dev

# Prerequisites for Fedora-based distributions:
sudo dnf install cmake gcc gcc-c++ bison re2c libxml2-devel sqlite-devel

# Prerequisites for BSD-based systems:
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

## Introduction

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
Ninja, versatile SCons, adaptable Meson, nimble xmake, and even the simplest
manual usage of Make.

## PHP directory structure

To understand the PHP source code better, it would be beneficial to grasp its
directory structure. PHP is developed at the
[php-src GitHub repository](https://github.com/php/php-src).

After cloning the repository:

```sh
git clone https://github.com/php/php-src
cd php-src
```

you end up with a large monolithic repository consisting of C source code files,
PHP tests and other associated files:

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
    └─ dom/
       ├─ lexbor/                 # https://github.com/lexbor/lexbor
       └─ ...
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
          └─ ir/                  # Bundled part of IR framework https://github.com/dstogov/ir
             └─ dynasm/           # DynASM encoding engine
                ├─ minilua.c      # Customized Lua scripting language to build LuaJIT
                └─ ...
             ├─ gen_ir_fold_hash  # IR folding engine generator created at build
             ├─ ir_emit_<arch>.h  # IR folding engine rules generated by minilua
             ├─ minilua           # Executable tool created at build
             └─ ...
    └─ pcre/                      # The PCRE PHP extension
       ├─ pcre2lib/               # https://www.pcre.org/
       └─ ...
    ├─ skeleton/                  # Skeleton for new extensions using `ext/ext_skel.php`
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

## Why CMake?

At the time of this writing, CMake is actively developed, and many developers
may already be familiar with it, making C code more appealing to new
contributors. Numerous IDEs offer excellent CMake integration for C/C++
projects.

CMake shares many similarities with Autotools, which simplifies the learning
curve for those already accustomed to building C code using existing systems.

Notably, CMake features better out-of-the-box support on Windows systems, where
Autotools may encounter issues without additional adaptations and adjustments in
the build process.

Despite Autotools potentially seeming complex and arcane to new developers,
unfamiliar with it, it remains a robust and solid build system option for C/C++
projects on \*nix systems. Many large open-source projects use Autotools, and
some even incorporate it alongside CMake.

## Documentation

* [Introduction to CMake](/docs/cmake-intro.md)
* [CMake-based PHP build system](/docs/cmake.md)
* [Configuration](/docs/configuration.md)
* [Dependencies in C/C++ projects](/docs/dependencies.md)
* [CMake code style](/docs/cmake-code-style.md)
* [Autotools-based PHP build system](/docs/autotools.md)
* [Windows build system for PHP](/docs/windows.md)
* [PHP embed SAPI module](/docs/embed.md)
* [PHP installation](/docs/php-installation.md)
* [PHP build system evolution](/docs/evolution.md)
* [Introduction to C](/docs/c.md)

## Project status

CMake files in this repository are synced up to these upstream php-src Git
commits:

| Upstream php-src branch | Last included upstream php-src commit                          |
| ----------------------- | -------------------------------------------------------------- |
| master                  | [03547f6832](https://github.com/php/php-src/commit/03547f6832) |
| PHP-8.3                 | [b32a1cc76f](https://github.com/php/php-src/commit/b32a1cc76f) |
