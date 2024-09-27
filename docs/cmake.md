# CMake-based PHP build system

This document describes how CMake-based PHP build system in this repository
works and how it can be used.

## Index

* [1. Directory structure](#1-directory-structure)
* [2. Build system diagram](#2-build-system-diagram)
* [3. Build requirements](#3-build-requirements)
* [4. CMake generators for building PHP](#4-cmake-generators-for-building-php)
  * [4.1. Unix Makefiles (default)](#41-unix-makefiles-default)
  * [4.2. Ninja](#42-ninja)
* [5. Build types](#5-build-types)
* [6. CMake minimum version for PHP](#6-cmake-minimum-version-for-php)
* [7. Interface library](#7-interface-library)
* [8. PHP CMake modules](#8-php-cmake-modules)
* [9. Custom CMake properties](#9-custom-cmake-properties)
* [10. PHP extensions](#10-php-extensions)
* [11. PHP SAPI (Server API) modules](#11-php-sapi-server-api-modules)
* [12. Generated files](#12-generated-files)
  * [12.1. Parser and lexer files](#121-parser-and-lexer-files)
* [13. Performance](#13-performance)
* [14. Testing](#14-testing)
* [15. Windows notes](#15-windows-notes)
  * [15.1. Module-definition (.def) files](#151-module-definition-def-files)

## 1. Directory structure

CMake-based PHP build system is a collection of various files across the php-src
repository:

```sh
🗁 <php-src>
 └─🗁 cmake                      # CMake-based PHP build system files
    └─🗁 modules                 # Project-specific CMake modules
       ├─🗁 PHP                  # PHP utility modules
       ├─🗁 Zend                 # Zend utility modules
       ├─📄 Find*.cmake          # Find modules that support the find_package()
       └─📄 *.cmake              # Any possible additional utility modules
    ├─🗁 platforms               # Platform-specific configuration
    ├─🗁 presets                 # Presets included in CMakePresets.json
    ├─🗁 toolchains              # CMake toolchain files
    └─📄 *.cmake                 # Various CMake configurations and tools
 └─🗁 ext
    └─🗁 date
       └─📄 CMakeLists.txt       # Extension's CMake file
    └─🗁 iconv
       ├─📄 CMakeLists.txt
       └─📄 php_iconv.def        # Module-definition for building DLL on Windows
    └─🗁 mbstring
       └─🗁 libmbfl
          └─📄 config.h.in       # Configuration header template for libmbfl
 └─🗁 main
    ├─📄 internal_functions.c.in # Template for internal functions files
    ├─📄 CMakeLists.txt          # CMake file for main binding
    ├─📄 config.w32.cmake.h.in   # Windows configuration header template
    └─📄 php_config.cmake.h.in   # Configuration header template
 └─🗁 pear
    └─📄 CMakeLists.txt          # CMake file for PEAR
 └─🗁 sapi
    └─🗁 cli
       └─📄 CMakeLists.txt       # CMake file for PHP SAPI module
 └─🗁 scripts
    └─📄 CMakeLists.txt          # CMake file for creating scripts files
 └─🗁 TSRM
    └─📄 CMakeLists.txt          # CMake file for thread safe resource manager
 └─🗁 win32                      # Windows build files
    └─ build                     # Windows build files
       └─📄 wsyslog.mc           # Message template file for win32/wsyslog.h
    └─📄 CMakeLists.txt          # CMake file for Windows build
 └─🗁 Zend
    └─📄 CMakeLists.txt          # CMake file for Zend engine
 ├─📄 CMakeLists.txt             # Root CMake file
 ├─📄 CMakePresets.json          # Main CMake presets file
 └─📄 CMakeUserPresets.json      # Git ignored local CMake presets overrides
```

The following diagram briefly displays, how PHP libraries (in terms of a build
system) are linked together:

![Diagram how PHP libraries are linked together](/docs/images/links.svg)

## 2. Build system diagram

![CMake-based PHP build system diagram](/docs/images/cmake.svg)

## 3. Build requirements

Before you can build PHP using CMake, you must first install certain third-party
requirements. It's important to note that the names of these requirements may
vary depending on your specific system. For the sake of simplicity, we will use
generic names here. When building PHP from source, one crucial requirement is a
library containing development files. Such libraries are typically packaged
under names like `libfoo-dev`, `libfoo-devel`, or similar conventions on \*nix
systems. For instance, to install the `libxml2` library, you would look for the
`libxml2-dev` (or `libxml2-devel`) package.

Required:

* cmake
* gcc
* g++
* libxml2
* libsqlite3

Additionally required when building from Git repository source code:

* bison

Optional when building from Git repository source code:

* re2c

When PHP is built, the development libraries are no longer required to be
installed and only libraries without development files are needed to run newly
built PHP. In example of `ext/libxml` extension, the `libxml2` package is needed
without the `libxml2-dev` and so on.

## 4. CMake generators for building PHP

When using CMake to build PHP, you have the flexibility to choose from various
build systems through the concept of _generators_. CMake generators determine
the type of project files or build scripts that CMake generates from the
`CMakeLists.txt` files.

### 4.1. Unix Makefiles (default)

The Unix Makefiles generator is the most commonly used for building projects on
Unix-like systems. It generates traditional `Makefile` that can be processed by
the `make` command. To use the Unix Makefiles generator, you simply specify it
as an argument when running CMake in your build directory.

To generate the `Makefile` for building PHP, create a new directory (often
called `build` or `cmake-build`) and navigate to it using the terminal. Then,
execute the following CMake command:

```sh
cmake -G "Unix Makefiles" /path/to/php-src
```

Replace `/path/to/php-src` with the actual path to the PHP source code on your
system (in case build directory is the same as the source directory, use `.`).
CMake will process the `CMakeLists.txt` file in the source directory and
generate the `Makefile` in the current build directory.

After the Makefiles are generated, you can build PHP binaries and libraries by
running:

```sh
cmake --build <build-directory> -j
```

If you want to speed up the build process, you can use the `-j` option to enable
parallel builds, taking advantage of multiple CPU cores.

> [!NOTE]
> On some systems, the `-j` option requires argument. Number of simultaneous
> jobs is often the number of available processor threads of the build machine
> and can be also automatically calculated using the `$(nproc)` on Linux, or
> `$(sysctl -n hw.ncpu)` on macOS and BSD-based systems.
>
> ```sh
> cmake --build <build-directory> -j $(nproc)
> ```

The `cmake --build` is equivalent to running the `make` command:

```sh
make -j $(nproc) # Number of CPUs you want to utilize.
```

### 4.2. Ninja

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
cmake --build <build-directory>
```

Which is equivalent to running `ninja` command. Ninja will then handle the build
process based on the CMake configuration. Ninja by default enables parallel
build.

## 5. Build types

CMake build types dictate compiler and linker flags, as well as the behavior
governing the compilation of source code based on the targeted deployment type.
Several common build types are pre-configured and readily available:

* Debug
* Release
* MinSizeRel
* RelWithDebInfo
* DebugAssertions (custom PHP build type)

The selection of a build type varies depending on the generator in use.

For single configuration generators, such as `Unix Makefiles` and `Ninja`, the
build type is designated during the configuration phase using the cache variable
`CMAKE_BUILD_TYPE`:

```sh
cmake -DCMAKE_BUILD_TYPE=Debug -S ../php-src -B build-directory
```

Multi configuration generators, like `Ninja Multi-Config` and Visual Studio,
employ the `--config` build option during the build phase:

```sh
cmake -G "Ninja Multi-Config" -S ../php-src -B build-directory
cmake --build build-directory --config Debug -j
```

Alternatively, multi configuration generators can specify build type in the
CMake presets JSON file using the `configuration` field:

```json
"buildPresets": [
  {
    "...": "...",
    "configuration": "Debug"
  }
],
```

## 6. CMake minimum version for PHP

The minimum required version of CMake is defined in the top project file
`CMakeLists.txt` using the `cmake_minimum_required()`. Picking the minimum
required CMake version is a compromise between CMake functionalities and CMake
version available on the operating system.

* 3.17
  * `CMAKE_CURRENT_FUNCTION_LIST_DIR` variable
* 3.19
  * `check_compiler_flag()`, `check_source_compiles()`, `check_source_runs()` to
    generalize the `check_<LANG>_...()`
  * `CMakePresets.json` for sharing build configurations
* 3.20
  * `CMAKE_C_BYTE_ORDER`, otherwise manual check should be done
  * `"version": 2` in `CMakePresets.json`
  * `Intl::Intl` IMPORTED target with CMake's FindIntl module
* 3.21
  * `"version": 3` in `CMakePresets.json` (for the `installDir` field)
* 3.22
  * Full condition syntax in `cmake_dependent_option()`
* 3.23
  * `target_sources(FILE_SET)`, otherwise `install(FILES)` should be used when
    installing files to their destinations
  * `"version": 4` in `CMakePresets.json` (for the `include` field)
* 3.24
  * `CMAKE_COLOR_DIAGNOSTICS`
  * `CMAKE_COMPILE_WARNING_AS_ERROR`, otherwise INTERFACE library should be used
* 3.25
  * `block()` command
  * New `try_run` signature
  * `cmake_language()` keyword `GET_MESSAGE_LOG_LEVEL`
* 3.27
  * `COMPILE_ONLY` generator expression
  * `INSTALL_PREFIX` generator expression in `install(CODE)`
* 3.29
  * `CMAKE_LINKER_TYPE`

Currently, the CMake minimum version is set to **3.25** without looking at CMake
available version on the current systems out there. This will be updated more
properly in the future.

CMake versions scheme across the systems is available at
[pkgs.org](https://pkgs.org/download/cmake).

> [!TIP]
> While the CMake version on some systems may be outdated, there are various
> options available to install the latest version. For instance, on Ubuntu, the
> most recent CMake version can be installed using `snap` or through the
> [APT repository](https://apt.kitware.com/).

## 7. Interface library

The `php_configuration` library (aliased `PHP::configuration`) holds
project-wide compilation flags, definitions, libraries and include directories.

It is analogous to a global configuration class, where configuration is set
during the configuration phase and then linked to targets that need the
configuration.

It can be linked to a given target:

```cmake
target_link_libraries(target_name PRIVATE PHP::configuration)
```

## 8. PHP CMake modules

All PHP CMake utility modules are located in the `cmake/modules/PHP` directory.

Here are listed only those that are important when adapting PHP build system.
Otherwise, a new module can be added by creating a new CMake file
`cmake/modules/PHP/NewModule.cmake` and then include it in the CMake code:

```cmake
include(PHP/NewModule)
```

* [PHP/CheckBuiltin](/docs/cmake-modules/PHP/CheckBuiltin.md)
* [PHP/CheckCompilerFlag](/docs/cmake-modules/PHP/CheckCompilerFlag.md)
* [PHP/SearchLibraries](/docs/cmake-modules/PHP/SearchLibraries.md)

## 9. Custom CMake properties

* `PHP_ALL_EXTENSIONS`

  Global property set by the [`PHP/Extensions`](cmake-modules/PHP/Extensions.md)
  module.

* `PHP_ALWAYS_ENABLED_EXTENSIONS`

  Global property set by the [`PHP/Extensions`](cmake-modules/PHP/Extensions.md)
  module.

* `PHP_EXTENSIONS`

  Global property set by the [`PHP/Extensions`](cmake-modules/PHP/Extensions.md)
  module.

* `PHP_PRIORITY`

  Directory property set by the
  [`PHP/Extensions`](cmake-modules/PHP/Extensions.md) module.

* `PHP_THREAD_SAFETY`

  Target property set by the
  [`PHP/ThreadSafety`](cmake-modules/PHP/ThreadSafety.md) module on the
  `PHP::configuration` target, when thread safety is enabled.

* `PHP_ZEND_EXTENSION`

  See the [`PHP/Extensions`](cmake-modules/PHP/Extensions.md) module.

## 10. PHP extensions

PHP has several ways to install PHP extensions:

* Statically linked to PHP

  This is the default way. Extension is built together with PHP SAPI and no
  enabling is needed in the `php.ini` configuration.

* Shared modules

  This installs the extension as dynamically loadable library. Extension to be
  visible in the PHP SAPI (see `php -m`) needs to be also manually enabled in
  the `php.ini` configuration:

  ```ini
  extension=php_extension_lowercase_name
  ```

  This will load the PHP extension module file (shared object) located in the
  extension directory (the `extension_dir` INI directive). File can have `.so`
  extension on *nix systems, `.dll` on Windows, and possibly other extensions
  such as `.sl` on certain HP-UX systems, or `.dylib` on macOS.

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

To build PHP extensions with CMake, a `CMakeLists.txt` file needs to be added to
the extension's source directory.

Example of `CMakeLists.txt` for PHP extensions can be found in the
`ext/skeleton` directory.

## 11. PHP SAPI (Server API) modules

PHP works through the concept of SAPI modules located in the `sapi` directory.

When running PHP on the command line, the cli SAPI module is used:

```sh
/sapi/cli/php -v
```

* [Embed SAPI module](/docs/embed.md)

There are other SAPI modules located in the ecosystem:

* [frankenphp](https://github.com/dunglas/frankenphp)
* [ngx-php](https://github.com/rryqszq4/ngx-php)
* ...

## 12. Generated files

During the build process, there are several files generated, some of which are
also tracked in the Git repository for a smoother workflow:

```sh
🗁 <php-src>
 └─🗁 ext
    └─🗁 date
       └─🗁 lib
          └─📄 timelib_config.h # Datetime library configuration header
    └─🗁 mbstring
       └─🗁 libmbfl
          └─📄 config.h         # The libmbfl configuration header
    └─🗁 tokenizer
       └─📄 tokenizer_data.c    # Generated token types data file
 └─🗁 main
    ├─📄 internal_functions*.c  # Generated files with all internal functions
    ├─📄 config.w32.h           # Main configuration header for Windows
    ├─📄 php_config.h           # Main configuration header for *nix systems
    └─📄 php_version.h          # Generated by release managers using `configure`
 └─🗁 scripts
    ├─📄 php-config             # PHP configuration helper script
    └─📄 phpize                 # Build configurator for PHP extensions
 └─🗁 win32                     # Windows build files
    ├─📄 cp_enc_map.c           # Generated from win32/cp_enc_map_gen.c
    └─📄 wsyslog.h              # Generated by message compiler (mc.exe or windmc)
 └─🗁 Zend
    └─📄 zend_config.w32.h      # Zend engine configuration header for Windows
```

### 12.1. Parser and lexer files

So-called parser files are generated with
[bison](https://www.gnu.org/software/bison/) tool from `*.y` source files to C
source code and header files.

Lexer files are generated with [re2c](https://re2c.org/) tool from `*.l` and
`*.re` source files to C source code and header files.

To use `bison` and `re2c` in CMake the `FindBison` and `FindRE2C` modules
provide `bison_target()` and `re2c_target()` commands.
[FindBison](https://cmake.org/cmake/help/latest/module/FindBISON.html) is a
CMake built-in module, while `FindRE2C` is manually created at
`cmake/modules/FindRE2C`.

Files related to `bison` and `re2c`:

```sh
🗁 <php-src>
 └─🗁 cmake
    └─🗁 modules
       └─📄 FindRE2C.cmake            # re2c CMake find module, bison is found via
                                      # CMake built-in find module
    └─📄 Requirements.cmake           # Minimum bison and re2c settings
 └─🗁 ext
    └─🗁 date
       └─🗁 lib
          ├─📄 parse_date.c           # Generated with re2c 0.15.3
          └─📄 parse_iso_intervals.c  # Generated with re2c 0.15.3
    └─🗁 ffi
       └─📄 ffi_parser.c              # Generated by https://github.com/dstogov/llk
    └─🗁 json
       ├─📄 json_parser.tab.c         # Generated with bison
       ├─📄 json_parser.tab.h         # Generated with bison
       ├─📄 json_parser.y             # Parser source
       ├─📄 json_scanner.c            # Generated with re2c
       ├─📄 json_scanner.re           # Lexer source
       └─📄 php_json_scanner_defs.h   # Generated with re2c
    └─🗁 pdo
       ├─📄 pdo_sql_parser.c          # Generated with re2c
       └─📄 pdo_sql_parser.re         # Source for re2c
    └─🗁 pdo_mysql
       ├─📄 mysql_sql_parser.c        # Generated with re2c
       └─📄 mysql_sql_parser.re       # Source for re2c
    └─🗁 pdo_pgsql
       ├─📄 pgsql_sql_parser.c        # Generated with re2c
       └─📄 pgsql_sql_parser.re       # Source for re2c
    └─🗁 pdo_sqlite
       ├─📄 sqlite_sql_parser.c       # Generated with re2c
       └─📄 sqlite_sql_parser.re      # Source for re2c
    └─🗁 phar
       ├─📄 phar_path_check.c         # Generated with re2c
       └─📄 phar_path_check.re        # Source for re2c
    └─🗁 standard
       ├─📄 url_scanner_ex.c          # Generated with re2c
       ├─📄 url_scanner_ex.re         # Source for re2c
       ├─📄 var_unserializer.c        # Generated with re2c
       └─📄 var_unserializer.re       # Source for re2c
 └─🗁 sapi
    └─🗁 phpdbg
       ├─📄 phpdbg_lexer.c            # Generated with re2c
       ├─📄 phpdbg_lexer.l            # Source for re2c
       ├─📄 phpdbg_parser.c           # Generated with bison
       ├─📄 phpdbg_parser.h           # Generated with bison
       ├─📄 phpdbg_parser.y           # Source for bison
       └─📄 phpdbg_parser.output      # Generated with bison
 └─🗁 Zend
    ├─📄 zend_ini_parser.c            # Generated with bison
    ├─📄 zend_ini_parser.h            # Generated with bison
    ├─📄 zend_ini_parser.output       # Generated with bison
    ├─📄 zend_ini_parser.y            # Parser source
    ├─📄 zend_ini_scanner.c           # Generated with re2c
    ├─📄 zend_ini_scanner.l           # Lexer source
    ├─📄 zend_ini_scanner_defs.h      # Generated with re2c
    ├─📄 zend_language_parser.c       # Generated with bison
    ├─📄 zend_language_parser.h       # Generated with bison
    ├─📄 zend_language_parser.output  # Generated with bison
    ├─📄 zend_language_parser.y       # Parser source
    ├─📄 zend_language_scanner_defs.h # Generated with re2c
    ├─📄 zend_language_scanner.c      # Generated with re2c
    └─📄 zend_language_scanner.l      # Lexer source
```

When building PHP from the released archives (`php-*.tar.gz`) from
[php.net](https://www.php.net/downloads.php) these files are already included in
the tarball itself so `re2c` and `bison` are not required.

These are generated automatically when building PHP from the Git repository.

To re-generate these files manually apart from the main build itself, a separate
CMake target `php_generate_files` can be used:

```sh
cmake -S <source-dir> -B <build-dir>
cmake --build <build-dir> -t php_generate_files
```

## 13. Performance

When CMake is doing configuration phase, the profiling options can be used to do
build system performance analysis of CMake files.

```sh
cmake --profiling-output ./profile.json --profiling-format google-trace ../php-src
```

![CMake profiling](/docs/images/cmake-profiling.png)

## 14. Testing

PHP source code tests (`*.phpt` files) are written in PHP and are executed with
`run-tests.php` script from the very beginning of the PHP development. When
building PHP with Autotools the tests are usually run by:

```sh
make TEST_PHP_ARGS=-j10 test
```

CMake ships with a `ctest` utility that can run PHP tests in a similar way.

To enable testing the `enable_testing()` is added to the `CMakeLists.txt` file
and the tests are added with `add_test()`.

To run the tests using CMake on the command line:

```sh
ctest --progress --verbose
```

The `--progress` option displays a progress if there are more tests, and
`--verbose` option outputs additional info to the stdout. In PHP case the
`--verbose` is needed so the output of the `run-tests.php` script is displayed.

CMake testing also supports presets so configuration can be coded and shared
using the `CMakePresets.json` file and its `testPresets` field.

```sh
ctest --preset all-enabled
```

## 15. Windows notes

### 15.1. Module-definition (.def) files

[Module-definition (.def) files](https://learn.microsoft.com/en-us/cpp/build/reference/module-definition-dot-def-files)
are added to certain php-src folders where linker needs them when building DLL.

In CMake they can be simply added to the target sources:

```cmake
target_sources(php_extension_name php_extension_name.def)
```
