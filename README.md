# PHP build system

[![PHP version](https://img.shields.io/badge/PHP-8.6-777BB4?logo=php&labelColor=17181B)](https://www.php.net/)
[![CMake version](https://img.shields.io/badge/CMake-4.2-064F8C?logo=cmake&labelColor=17181B)](https://cmake.org)
[![C11](https://img.shields.io/badge/standard-C11-A8B9CC?logo=C&labelColor=17181B)](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf)

This repository delves into the core of the PHP build system, elucidating the
intricacies of how to build PHP with CMake.

![ElePHPant](docs/images/elephpant.jpg)

## Quick usage - TL;DR

### Step 1 - Install prerequisites

```sh
# Prerequisites for Debian-based distributions:
sudo apt install cmake gcc g++ libsqlite3-dev

# Prerequisites for Fedora-based distributions:
sudo dnf install cmake gcc gcc-c++ sqlite-devel
```

<details>
  <summary>Click here for more platforms</summary>

  ```sh
  # Prerequisites for macOS:
  xcode-select --install   # XCode command line tools
  brew install cmake # See https://brew.sh how to install Homebrew

  # Prerequisites for Alpine Linux:
  sudo apk add --no-cache cmake make gcc g++ musl-dev sqlite-dev

  # Prerequisites for BSD-based systems:
  sudo pkg install cmake sqlite3

  # Prerequisites for Haiku:
  pkgman install cmake sqlite_devel

  # Prerequisites for Solaris/illumos-based systems:
  sudo pkg install cmake sqlite-3
  ```
</details>

### Step 2 - Clone this repository

```sh
git clone https://github.com/petk/php-build-system

cd php-build-system
```

### Step 3 - Generate build system to a build directory

```sh
cmake -B php-build
```

### Step 4 - Build PHP in parallel

```sh
cmake --build php-build -j
```

After build is complete, a PHP binary should be available to run:

```sh
./php-build/php/sapi/cli/php -v
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
to establish a structured framework that guides how code should be written.
Beyond its primary role of compiling source files into executable programs, the
build system plays a pivotal educational role, imparting best practices and
coding standards to developers. By enforcing consistency and adherence to coding
conventions, it fosters the creation of high-quality code, ultimately enhancing
software maintainability and reliability.

Additionally, the build system aims to enable developers to work efficiently by
abstracting away system-specific details, allowing them to focus on the logic
and usability of their code. When adding a new source file or making minor
modifications, developers shouldn't have to delve into the inner workings of the
build system, sift through extensive build system documentation or extensively
explore the complexities of the underlying system.

There are numerous well-known build systems available, ranging from the veteran
GNU Autotools and the widely adopted CMake, to the efficient Ninja, versatile
SCons, adaptable Meson, nimble xmake, cutting-edge Zig build system, and even
the simplest manual usage of Make.

## PHP directory structure

To understand the PHP source code better, it would be beneficial to grasp its
directory structure. PHP is developed at the
[php-src GitHub repository](https://github.com/php/php-src).

After cloning the repository:

```sh
git clone https://github.com/php/php-src
cd php-src
```

there is a large monolithic repository consisting of C source code files, PHP
tests and other associated files:

```sh
📂 <php-src>
├─📂 .git                        # Git configuration and source directory
├─📂 benchmark                   # Benchmark some common applications in CI
├─📂 build                       # *nix build system files
├─📂 docs                        # PHP internals documentation
└─📂 ext                         # PHP core extensions
  └─📂 bcmath                    # The bcmath PHP extension
    ├─📂 libbcmath               # The bcmath library forked and maintained in php-src
    ├─📂 tests                   # *.phpt test files for extension
    ├─📄 bcmath.stub.php         # A stub file for the bcmath extension functions
    └─📄 ...
  └─📂 curl                      # The curl PHP extension
    ├─📄 sync-constants.php      # The curl symbols checker
    └─📄 ...
  └─📂 date                      # The date/time PHP extension
    └─📂 lib                     # Bundled datetime library https://github.com/derickr/timelib
      └─📄 ...
    └─📄 ...
  ├─📂 dl_test                   # Extension for testing dl()
  └─📂 ffi                       # The FFI PHP extension
    ├─📄 ffi_parser.c            # Generated by https://github.com/dstogov/llk
    └─📄 ...
  └─📂 fileinfo                  # The fileinfo PHP extension
    ├─📂 libmagic                # Modified libmagic https://github.com/file/file
    ├─📄 data_file.c             # Generated by `ext/fileinfo/create_data_file.php`
    ├─📄 libmagic.patch          # Modifications patch from upstream libmagic
    ├─📄 magicdata.patch         # Modifications patch from upstream libmagic
    └─📄 ...
  └─📂 gd                        # The GD PHP extension
    ├─📂 libgd                   # Bundled and modified GD library https://github.com/libgd/libgd
    └─📄 ...
  └─📂 lexbor
    ├─📂 lexbor                  # https://github.com/lexbor/lexbor
    └─📄 ...
  └─📂 mbstring                  # The Multibyte string PHP extension
    ├─📂 libmbfl                 # Forked and maintained in php-src
    ├─📄 unicode_data.h          # Generated by `ext/mbstring/ucgendat/ucgendat.php`
    └─📄 ...
  └─📂 opcache                   # The OPcache PHP extension
    └─📂 jit                     # OPcache Jit
      └─📂 ir                    # Bundled part of IR framework https://github.com/dstogov/ir
        └─📂 dynasm              # DynASM encoding engine
          ├─📄 minilua.c         # Customized Lua scripting language to build LuaJIT
          └─📄 ...
        ├─📄 gen_ir_fold_hash    # IR folding engine generator created at build
        ├─📄 ir_emit_<arch>.h    # IR folding engine rules generated by minilua
        ├─📄 minilua             # Executable tool created at build
        └─📄 ...
  └─📂 pcre                      # The PCRE PHP extension
    ├─📂 pcre2lib                # https://www.pcre.org/
    └─📄 ...
  └─📂 phar                      # The Phar (PHP Archive) PHP extension
    ├─📄 stub.h                  # Generated by `ext/phar/{makestub,shortarc}.php`
    └─📄 ...
  ├─📂 skeleton                  # Skeleton for new extensions using `ext/ext_skel.php`
  └─📂 standard                  # Always enabled core extension
    └─📂 html_tables
      ├─📂 mappings              # https://www.unicode.org/Public/MAPPINGS/
      └─📄 ...
    ├─📄 credits_ext.h           # Generated by `scripts/dev/credits`
    ├─📄 credits_sapi.h          # Generated by `scripts/dev/credits`
    ├─📄 html_tables.h           # Generated by `ext/standard/html_tables/html_table_gen.php`
    └─📄 ...
  └─📂 tokenizer                 # The tokenizer PHP extension
    ├─📄 tokenizer_data.c        # Generated by `ext/tokenizer/tokenizer_data_gen.php`
    ├─📄 tokenizer_data_stub.php # Generated by `ext/tokenizer/tokenizer_data_gen.php`
    └─📄 ...
  └─📂 uri
    ├─📂 uriparser               # https://github.com/uriparser/uriparser
    └─📄 ...
  └─📂 zend_test                 # For testing internal APIs. Not needed for regular builds
    └─📄 ...
  └─📂 zip/                      # Bundled https://github.com/pierrejoye/php_zip
    └─📄 ...
  ├─📂 ...
  └─📄 ext_skel.php              # Helper script that creates a new PHP extension
└─📂 main                        # Binding that ties extensions, SAPIs, and Zend Engine together
  ├─📂 streams                   # Streams layer subsystem
  ├─📄 debug_gdb_scripts.c       # Generated by `scripts/gdb/debug_gdb_scripts_gen.php`
  └─📄 ...
├─📂 modules                     # Shared libraries, created when building PHP
├─📂 pear                        # PEAR installation
└─📂 sapi                        # PHP SAPI (Server API) modules
  └─📂 cli                       # Command-line PHP SAPI module
    ├─📄 mime_type_map.h         # Generated by `sapi/cli/generate_mime_type_map.php`
    └─📄 ...
  └─📄 ...
├─📂 scripts                     # php-config, phpize and internal development scripts
├─📂 tests                       # Core features tests
├─📂 TSRM                        # Thread Safe Resource Manager
└─📂 Zend                        # Zend Engine
  ├─📂 asm                       # Bundled from src/asm in https://github.com/boostorg/context
  ├─📂 Optimizer                 # For faster PHP execution through opcode caching and optimization
  ├─📂 tests                     # PHP tests *.phpt files for Zend Engine
  ├─📄 zend_vm_execute.h         # Generated by `Zend/zend_vm_gen.php`
  ├─📄 zend_vm_opcodes.c         # Generated by `Zend/zend_vm_gen.php`
  ├─📄 zend_vm_opcodes.h         # Generated by `Zend/zend_vm_gen.php`
  └─📄 ...
├─📂 win32                       # Windows build files
└─📄 ...
```

## Why CMake?

At the time of writing, CMake is actively maintained, with new features being
introduced slowly and conservatively. Despite its limitations, it remains one of
the most widely adopted build systems, offering solid support across all major
platforms. Many developers are already familiar with CMake, which can help lower
the barrier for contributors working with the PHP codebase. IDEs and editors
provide reasonably good CMake integration for C/C++ projects.

## Documentation

* CMake
  * [Introduction to CMake](/docs/cmake/introduction.md)
  * [CMake-based PHP build system](/docs/cmake/cmake.md)
  * [Configuration](/docs/cmake/configuration.md)
  * [CMake code style](/docs/cmake/cmake-code-style.md)
  * [PHP native and CMake-based build system differences](/docs/cmake/differences.md)
* [Dependencies in C/C++ projects](/docs/dependencies.md)
* [Autotools-based PHP build system](/docs/autotools/README.md)
* [Windows build system for PHP](/docs/windows/README.md)
* [Cross-compiling](/docs/cross-compiling.md)
* [PHP build system evolution](/docs/evolution.md)
* [Introduction to C](/docs/c.md)
* [Frequently asked questions](/docs/faq.md)
