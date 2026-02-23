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

## PHP native and CMake-based build system differences

How CMake-based PHP build system differs compared to its Autotools and Windows
build system:

### Enhancement differences

The following features are only available in CMake:

* `re2c` tool can be automatically downloaded, when not found on the system

* Added pkg-config .pc files

  Once installed, there are three .pc files available in system `pkgconfig`
  directory:

  * php.pc - for building PHP extensions
  * php-embed.pc - for embedding PHP into application
  * phpdbg.pc - for PHP Debugger SAPI module library.

    These can be then used with the pkg-config (pkgconf) tool:

    ```sh
    pkg-config --cflags php
    pkg-config --cflags-only-I php
    pkg-config --libs php
    pkg-config --mod-version php
    pkg-config --print-variables php
    pkg-config --variable=php_vernum php
    ```

    Upstream Autotools-based draft: https://github.com/php/php-src/pull/13755

* CMake presets simplify the build configurations. The native PHP Autotools
  build system has issues with the `--enable-all` option, where certain
  configuration options are set but they also set additional variables (e.g.,
  `ext_shared`) where they shouldn't. PHP Windows build system has similar
  configure option `--enable-snapshot-build` (and `--disable-all`).

* Better cross-compiling support with CMake toolchain files and ability to set
  the cross-compiling emulator.

* Additional configuration options:

  * `PHP_CONFIGURE_COMMAND`

### Behavior differences

* sapi/phpdbg readline support works more intuitively regardless of the readline
  extension being enabled during the build.

* sapi/phpdbg shared library name on Windows is synced with \*nix systems
  (`libphpdbg`).

* ext/session can be built as shared on Windows (in testing phase).

* Obsolete check whether the `dlsym()` requires a leading underscore in symbol
  name is removed in CMake.
  See: https://github.com/php/php-src/pull/13655

* Compiler shipped with Oracle Developer Studio is not supported.
  See: https://github.com/php/php-src/issues/15272

* ext/phar doesn't have native SSL support anymore in favor of SSL through the
  PHP openssl extension:
  See: https://github.com/php/php-src/pull/15574

* ext/ldap in CMake has configuration option (following Autotools) to explicitly
  enable SASL support on both platform types (\*nix and Windows), while Windows
  JScript build system has SASL support always unconditionally enabled.

* ext/mysqli and ext/pdo_mysql have each separate configuration options for
  setting the Unix socket pointer. In Autotools, there is a single
  `--with-mysql-socket` configure option that is used by both extensions. This
  is done on the expense of more complex configuration while being more
  intuitive and logical configuration similar to the PHP INI directives of
  `mysqli.default_socket` and `pdo_mysql.default_socket`. In Autotools, default
  socket paths are in some cases defined in a hacky way. The `pdo_mysql`
  extension has default set to `/tmp/mysql.sock`, without possibility to be set
  to `NULL`.

* The `_XOPEN_SOURCE` compile definition to use ucontext.h on macOS when needed
  is only defined for the Zend/zend_fibers.c file. Duplicate inconsistent
  `_XOPEN_SOURCE` definition in the php_config.h is also removed with this.

* In CMake the install prefix can be also changed during the installation phase
  using the `cmake --install <build-dir> --prefix <install-prefix>`. In PHP
  native Autotools-based build system, installation prefix can be only set at
  the configure phase using the `./configure --prefix=<install-prefix>`, which
  is a regression for the `main/build-defs.h` and `main/php_config.h` files,
  where the installation prefix in PHP is hardcoded during the build phase and
  cannot be changed during the installation phase. For the generated files
  (php-config, pkg-config .pc, etc.) workaround is already done in CMake but not
  yet for the header files.
  See: https://github.com/petk/php-build-system/issues/4

* CMake configuration mostly follows Autotools defaults aiming to be consistent.
  In native PHP build system there are various extensions by default
  inconsistently enabled or disabled between Autotools and Windows.

  For example:

    * ext/bcmath (Windows: enabled, Autotools: disabled, CMake: disabled)
    * ext/calendar (Windows: enabled, Autotools: disabled, CMake: disabled)

  See [Configuration](/docs/cmake/configuration.md) documentation for more info.

* In CMake, shared extensions built in php-src and as standalone (a.k.a. in the
  phpize mode) are built in both ways with the hidden visibility preset.
  See: https://github.com/php/php-src/pull/21238

* Installation

  * The installation include directory (`/usr/local/include/php`) can be
    adjusted with the `PHP_INCLUDE_PREFIX` CMake cache variable to support
    multiple PHP versions. For example, `/usr/local/include/php/8.6`.

  * The installation lib directory (`/usr/local/lib/php`) can be
    adjusted with the `PHP_LIB_PREFIX` CMake cache variable to support
    multiple PHP versions. For example, `/usr/local/lib/php/8.6`.

  * The PHP Autotools layout configuration option `--with-layout=[PHP|GNU]` is
    in CMake removed and not implemented in favor of the GNU standard directory
    layout.

  * PEAR installation writes less dot and temporary files outside of the staging
    installation directory (INSTALL_ROOT/DESTDIR). PEAR temporary directory can
    be adjusted with the `PHP_PEAR_TEMP_DIR` CMake cache variable.

* Parser and lexer files

  * When generating parser (Bison) and lexer (re2c) files with command-line
    script `cmake/scripts/GenerateGrammar.cmake`, Bison report files
    (`*.output`) are not generated.

  * For the `Release` and `MinSizeRel` CMake build types, the Bison `--no-lines`
    (`-l`) and re2c `--no-debug-info` (`-i`) options are added.

* HP-UX platform is not supported in CMake-based build system anymore.
  See: https://github.com/php/php-src/pull/21280

* On Windows, there is also `main/build-defs.h` header added and included in the
  `main/config.w32.h` to be synced with \*nix configuration.

### Bugs fixed in CMake

* Building inside folder with spaces.
  See: https://bugs.php.net/49270

* Detecting GNU libiconv.
  See: https://github.com/php/php-src/issues/12213

* Oracle Instant Client integration in ldap extension is removed in CMake due to
  missing LDAP features causing build errors.
  See: https://github.com/php/php-src/issues/15051

* The phpdbg prompt with libedit integration is colored.
  See: https://github.com/php/php-src/pull/15722

* GPL 3 licensed dependencies are removed as they are not compatible with PHP
  license. When such dependencies are linked statically or dynamically, PHP
  should be relicensed as GPL 3 (which is unrealistic), or it shouldn't be
  distributed (which makes it unusable in server environments or package
  repositories). As this is a gray area, removal of these dependencies improves
  user experience and prevents misconfiguration.

  * GDBM (GNU dbm) handler removed in ext/dba.
    See: https://github.com/php/php-src/issues/16826

  * ext/readline is linked with libedit and GNU Readline removed.
    See: https://github.com/php/php-src/issues/15882

* Build with Clang on 32-bit systems.
  See: https://github.com/php/php-src/issues/14467

* `Zend/zend_vm_gen.php` deprecation warnings on 32-bit systems.
  See: https://github.com/php/php-src/issues/15899

* The `chroot()` PHP function is enabled/disabled based on the SAPI type.
  See: https://github.com/php/php-src/issues/11984

* The libmbfl configuration header (`config.h`).
  See: https://github.com/php/php-src/pull/13713

* Building with large number of CPU cores might emit errors.

  When building PHP with Autotools in parallel with large number of CPU cores
  (`make -j32`) there might happen error like this with very small
  reproducibility:

  ```
  ...tokenizer_data.c:22:10: fatal error: zend_language_parser.h: No such file
  or directory
  ```

  There might be some misconfigured dependencies between some files in Makefile.
  For example, the `Zend/zend_language_parser.h` and all other Zend language
  parser files must be generated before the `ext/tokenizer` files start to
  build, otherwise error happens because Bison might generate header with slight
  delay.

  In CMake, this is bypassed by having entire extension dependent on the
  `PHP::Zend` target (which also includes the parser and scanner).

* The zlib extension can be built as shared and SWC files are supported.
  See: https://github.com/php/php-src/issues/20868

* The intl extension can be built with undefined sanitizer enabled. CMake picks
  C or C++ linker for SAPIs based on the objects being linked. Autotools would
  need a workaround using libtool tags.
  See: https://github.com/php/php-src/issues/20992

## Documentation

* CMake
  * [CMake-based PHP build system](/docs/cmake/cmake.md)
  * [Configuration](/docs/cmake/configuration.md)
  * [CMake code style](/docs/cmake/cmake-code-style.md)
* [Dependencies in C/C++ projects](/docs/dependencies.md)
* [Autotools-based PHP build system](/docs/autotools/README.md)
* [Windows build system for PHP](/docs/windows/README.md)
* [Cross-compiling](/docs/cross-compiling.md)
* [PHP build system evolution](/docs/evolution.md)
* [Introduction to C](/docs/c.md)
* [Frequently asked questions](/docs/faq.md)
