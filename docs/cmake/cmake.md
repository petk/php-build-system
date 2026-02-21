# CMake-based PHP build system

This document describes how CMake-based PHP build system in this repository
works and how it can be used.

## Index

* [1. Introduction](#1-introduction)
  * [1.1. Configuration and generation phase](#11-configuration-and-generation-phase)
  * [1.2. Build phase](#12-build-phase)
  * [1.3. CMake syntax](#13-cmake-syntax)
* [2. Directory structure](#2-directory-structure)
* [3. Build system diagram](#3-build-system-diagram)
* [4. Build requirements](#4-build-requirements)
* [5. CMake generators for building PHP](#5-cmake-generators-for-building-php)
  * [5.1. Unix Makefiles (default)](#51-unix-makefiles-default)
  * [5.2. Ninja](#52-ninja)
* [6. Build types](#6-build-types)
* [7. CMake minimum version for PHP](#7-cmake-minimum-version-for-php)
* [8. Interface libraries](#8-interface-libraries)
* [9. PHP CMake modules](#9-php-cmake-modules)
* [10. Custom CMake properties](#10-custom-cmake-properties)
* [11. PHP extensions](#11-php-extensions)
* [12. PHP SAPI (Server API) modules](#12-php-sapi-server-api-modules)
* [13. Generated files](#13-generated-files)
  * [13.1. Parser and lexer files](#131-parser-and-lexer-files)
* [14. Performance](#14-performance)
* [15. Testing](#15-testing)
* [16. Windows notes](#16-windows-notes)
  * [16.1. Module-definition (.def) files](#161-module-definition-def-files)
* [17. PHP installation](#17-php-installation)
  * [17.1. Installing PHP with CMake](#171-installing-php-with-cmake)
  * [17.2. Installation directory structure](#172-installation-directory-structure)
  * [17.3. Installation components](#173-installation-components)

## 1. Introduction

[CMake](https://cmake.org/) is an open-source, cross-platform meta build system
created by Kitware and contributors. It's not a build system *per se*, but
rather a build system generator that produces configuration files for specific
build systems, such as Unix Makefiles, Visual Studio projects, or Ninja build
files.

CMake is typically invoked from the command line using the `cmake` command. When
working with CMake, there are two primary phases: the configuration and
generation phase, where CMake sets up the project's build files, and the build
phase, where the target build system compiles the project.

### 1.1. Configuration and generation phase

In this phase, CMake performs essential tasks to set up a build environment. It
reads source files (`CMakeLists.txt`) from the source directory, configures the
build system, and generates the necessary build system files, such as Makefiles,
into a build directory.

```sh
# Generate build system from a source directory to a build directory
cmake -S source-dir -B build-dir
```

### 1.2. Build phase

The build phase involves transforming project C/C++ source files into libraries
and executables. During this phase, the project undergoes compilation and
assembly, preparing it for execution. The `--parallel` option (or short `-j`)
enables concurrent build processes for faster compilation.

```sh
# Build the project from the specified build directory
cmake --build build-dir --parallel
```

> [!NOTE]
> So-called **in-source builds** are a simplification when building inside a
> source directory (when source and build directories are the same):
>
> ```sh
> cmake .  # Same as: cmake -S . -B .
> cmake --build . --parallel
> ```
>
> The build system generates multiple files not intended to be tracked by Git.
> Therefore, it is recommended to establish a distinct build directory right
> from the start. For instance, a build directory can be also created within the
> source directory:
>
> ```sh
> cmake -B build-dir
> cmake --build build-dir --parallel
> ```

### 1.3. CMake syntax

CMake syntax consists of the following 3 elements:

* Comments (single and multi-line)
* Commands (functions and macros defined in modules, and CMake built-in
  commands)
* Command arguments

```cmake
# This is a line comment.

#[[
  This is a multi-line comment.
]]

some_command()

another_command(
  "quoted argument"
  [[bracket argument]]
  unquoted_argument
  ${variable}
)
```

To learn CMake and its syntax, it is highly recommended to start with the
[step-by-step tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html).

## 2. Directory structure

CMake-based PHP build system is a collection of various files across the php-src
repository:

```sh
📂 <php-src>
└─📂 cmake                     # CMake-based PHP build system files
  └─📂 modules                 # Project-specific CMake modules
    └─📂 PHP                   # PHP utility CMake modules
      ├─📂 Core                # Modules for php-src
      ├─📂 Internal            # Internal modules
      └─📄 ...                 # Modules for php-src and extensions
    └─📄 Find*.cmake           # Find modules that support the find_package()
  ├─📂 platforms               # Platform-specific configuration
  ├─📂 presets                 # Presets included in CMakePresets.json
  ├─📂 scripts                 # Various CMake command-line scripts
  ├─📂 tests                   # Tests for testing PHP CMake code itself
  ├─📂 toolchains              # CMake toolchain files
  └─📄 *.cmake                 # Various CMake configurations and files
└─📂 ext
  └─📂 date
    └─📂 lib
      └─📄 CMakeLists.txt      # Timelib's CMake file
  └─📂 mbstring
    └─📂 libmbfl
      └─📄 CMakeLists.txt      # libmbfl's CMake file
  └─📂 standard
    └─📂 cmake                 # Extension's CMake-related files
      └─📄 config.h.in         # Extension's configuration header template
    └─📄 CMakeLists.txt        # Extension's CMake file
  └─📂 zlib
    ├─📂 cmake
    ├─📄 CMakeLists.txt
    └─📄 php_iconv.def         # Module-definition for building DLL on Windows
└─📂 main
  └─📂 cmake                   # CMake-related files for main binding
    └─📄 php_config.h.in       # PHP main configuration header template
  ├─📄 CMakeLists.txt          # CMake file for main binding
  └─📄 internal_functions.c.in # Common template for internal functions files
└─📂 pear
  ├─📂 cmake                   # CMake-related files for PEAR
  └─📄 CMakeLists.txt          # CMake file for PEAR
└─📂 sapi
  └─📂 fpm
    └─📂 cmake                 # SAPI's CMake-related files
      └─📄 config.h.in         # SAPI's configuration header template
    └─📄 CMakeLists.txt        # CMake file for PHP SAPI module
└─📂 scripts
  └─📄 CMakeLists.txt          # CMake file for creating scripts
└─📂 tests
  └─📄 CMakeLists.txt          # CMake file for configuring PHP tests
└─📂 win32                     # Windows build files
  └─📂 build                   # Windows build files
    └─📄 wsyslog.mc            # Message template file for win32/wsyslog.h
  └─📄 CMakeLists.txt          # CMake file for Windows build
└─📂 Zend
  └─📂 cmake                   # CMake-related files for Zend Engine
    └─📄 zend_config.h.in      # Zend Engine configuration header template
  └─📄 CMakeLists.txt          # CMake file for Zend Engine
├─📄 CMakeLists.txt            # Root CMake file
├─📄 CMakePresets.json         # Main CMake presets file
└─📄 CMakeUserPresets.json     # Git ignored local CMake presets overrides
```

The following diagram briefly displays, how PHP libraries (in terms of a build
system) are linked together:

![Diagram how PHP libraries are linked together](/docs/images/links.svg)

## 3. Build system diagram

![CMake-based PHP build system diagram](/docs/images/cmake.svg)

## 4. Build requirements

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
* libsqlite3

Optional (if not found on the system, build system tries to download them):

* libxml2

Optional when building from Git repository source code (if not found on the
system, build system tries to download them):

* Bison
* re2c

When PHP is built, the development libraries are no longer required to be
installed and only libraries without development files are needed to run newly
built PHP. In example of `ext/libxml` extension, the `libxml2` package is needed
without the `libxml2-dev` and so on.

## 5. CMake generators for building PHP

When using CMake to build PHP, you have the flexibility to choose from various
build systems through the concept of _generators_. CMake generators determine
the type of project files or build scripts that CMake generates from the
`CMakeLists.txt` files.

### 5.1. Unix Makefiles (default)

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
cmake --build build-dir -j
```

If you want to speed up the build process, you can use the `-j` option to enable
parallel builds, taking advantage of multiple CPU cores.

> [!NOTE]
> On some systems, the `-j` option requires argument. Number of simultaneous
> jobs is often the number of available logical CPU cores (a.k.a threads) of
> the build machine and can be also automatically calculated using the
> `$(nproc)` on Linux, or `$(sysctl -n hw.ncpu)` on macOS and BSD-based systems.
>
> ```sh
> cmake --build build-dir -j $(nproc)
> ```

The `cmake --build` is equivalent to running the `make` command:

```sh
make -j $(nproc) # Number of CPUs you want to utilize.
```

### 5.2. Ninja

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
cmake --build build-dir
```

Which is equivalent to running `ninja` command. Ninja will then handle the build
process based on the CMake configuration. Ninja by default enables parallel
build.

## 6. Build types

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
cmake -DCMAKE_BUILD_TYPE=Debug -S ../php-src -B build-dir
```

Multi configuration generators, like `Ninja Multi-Config` and Visual Studio,
employ the `--config` build option during the build phase:

```sh
cmake -G "Ninja Multi-Config" -S ../php-src -B build-dir
cmake --build build-dir --config Debug -j
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

## 7. CMake minimum version for PHP

The minimum required version of CMake is defined in the top project file
`CMakeLists.txt` using the `cmake_minimum_required()`. Picking the minimum
required CMake version is a compromise between CMake functionalities and CMake
version available on the operating system. The minimum required CMake version in
this repository is **4.2**.

CMake versions scheme across the systems is available at
[pkgs.org](https://pkgs.org/download/cmake).

> [!TIP]
> While the CMake version on some systems may be outdated, there are various
> options available to install the latest version. There are binary
> [CMake](https://cmake.org/download/) downloads available for the most used
> platforms, there is a [`snap`](https://snapcraft.io/cmake) package, and
> [APT repository](https://apt.kitware.com/) for Debian-based distributions.

## 8. Interface libraries

* The `php_config` (aliased `PHP::config`) holds compilation and link
  properties, such as flags, definitions, libraries and include directories. All
  targets that need global PHP compile or link properties should link to this
  target.

  It is analogous to a global configuration class, where configuration is set
  during the configuration phase and then linked to targets that need the
  configuration.

  It can be linked to a given target:

  ```cmake
  target_link_libraries(target_name PRIVATE PHP::config)
  ```

* The `php_sapi` (aliased `PHP::sapi`) ties all target objects and configuration
  together. Only PHP SAPI targets should link to it.

  ```cmake
  target_link_libraries(<some-php-sapi-target> PRIVATE PHP::sapi)
  ```

See also https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html
for a high-level overview of the CMake build system concepts.

## 9. PHP CMake modules

All PHP global CMake utility modules are located in the `cmake/modules/PHP`
directory.

A new module can be added by creating a new CMake file
`cmake/modules/PHP/NewModule.cmake` which can be then included in the CMake
files:

```cmake
include(PHP/NewModule)
```

Additional CMake modules or other files that are used only inside a certain
subdirectory (extension, SAPI, Zend Engine...) are located in the `cmake`
directories where needed:

* `ext/<extension>/cmake/*.cmake` - CMake modules related to extension
* `sapi/<sapi>/cmake/*.cmake` - CMake modules related to SAPI
* `Zend/cmake/*.cmake` - CMake modules related to Zend Engine

A list of PHP CMake modules:

* [PHP/AddCommand](/docs/cmake/modules/PHP/AddCommand.md)
* [PHP/Bison](/docs/cmake/modules/PHP/Bison.md)
* [PHP/CheckAttribute](/docs/cmake/modules/PHP/CheckAttribute.md)
* [PHP/CheckBuiltin](/docs/cmake/modules/PHP/CheckBuiltin.md)
* [PHP/CheckCompilerFlag](/docs/cmake/modules/PHP/CheckCompilerFlag.md)
* [PHP/CheckSysMacros](/docs/cmake/modules/PHP/CheckSysMacros.md)
* [PHP/Extension](/docs/cmake/modules/PHP/Extension.md)
* [PHP/Re2c](/docs/cmake/modules/PHP/Re2c.md)
* [PHP/SearchLibraries](/docs/cmake/modules/PHP/SearchLibraries.md)
* [PHP/StandardLibrary](/docs/cmake/modules/PHP/StandardLibrary.md)
* [PHP/SystemExtensions](/docs/cmake/modules/PHP/SystemExtensions.md)
* [PHP/VerboseLink](/docs/cmake/modules/PHP/VerboseLink.md)

## 10. Custom CMake properties

* `PHP_ALL_EXTENSIONS`

  Global property with a list of all PHP extensions in the `ext` directory.

* `PHP_ALL_SAPIS`

  Global property with a list of all PHP SAPIs in the `sapi` directory.

* `PHP_ALWAYS_ENABLED_EXTENSIONS`

  Global property with a list of always enabled PHP extensions which can be
  considered part of the core PHP.

* `PHP_CLI`

  Target property that designates CMake target of PHP SAPI or extension as
  CLI-based (usable in a CLI environment). When enabled on a PHP SAPI target,
  such SAPI will have the `main/internal_functions_cli.c` object instead of
  `main/internal_functions.c` and objects of enabled CLI-based PHP extensions
  that were built statically.

  When this property is enabled on a PHP extension target, extension will be
  only listed in the generated `main/internal_functions_cli.c` file. Other
  extensions will be listed also in the `main/internal_functions.c` file.
  CLI-based extensions will only be enabled on CLI-based SAPIs.

  Examples of CLI-based SAPIs are `cgi`, `cli`, `phpdbg`, and `embed`. Examples
  of CLI-based extensions are `pcntl` and `readline`.

  For example, to mark some PHP SAPI as CLI-based, set `PHP_CLI` property to
  *truthy* value:

  ```cmake
  set_target_properties(php_sapi_cli PROPERTIES PHP_CLI TRUE)
  ```

  Basic generator expressions are also supported:

  ```cmake
  set_target_properties(
    php_ext_some_extension
    PROPERTIES PHP_CLI $<IF:$<PLATFORM_ID:Windows>,FALSE,TRUE>
  )
  ```

* `PHP_EXTENSION_<extension>_DEPS`

  Global property with a list of all dependencies of PHP `<extension>` (the name of
  the extension as named in `php-src/ext` directory).

* `PHP_EXTENSIONS`

  Global property with a list of all enabled PHP extensions for the current
  configuration. Extensions are sorted by their dependencies (extensions added
  with CMake command `add_dependencies()`).

* `PHP_SAPI_FASTCGI`

  Target property that marks the selected PHP SAPI target as FastCGI-related.
  These SAPIs get the `main/fastcgi.c` object linked in the binary. For example,
  PHP CGI and PHP FPM SAPIs.

* `PHP_SAPIS`

  Global property with a list of all enabled PHP SAPIs for the current
  configuration.

* `PHP_THREAD_SAFETY`

  A custom target property. When thread safety is enabled (either by the
  configuration variable `PHP_THREAD_SAFETY` or automatically by the
  `apache2handler` PHP SAPI), also a custom target property `PHP_THREAD_SAFETY`
  is added to the `PHP::config` target, which can be then used in generator
  expressions during the generation phase to determine thread safety enabled
  from the configuration phase. For example, the `PHP_EXTENSION_DIR`
  configuration variable needs to be set depending on the thread safety.

* `PHP_ZEND_EXTENSION`

  PHP extensions can utilize this custom target property, which designates the
  extension as a Zend extension rather than a standard PHP extension. Zend
  extensions function similarly to regular PHP extensions, but they are loaded
  using the `zend_extension` INI directive and possess an internally distinct
  structure with additional hooks. Typically employed for advanced
  functionalities like debuggers and profilers, Zend extensions offer enhanced
  capabilities.

  ```cmake
  set_target_properties(php_ext_<extension_name> PROPERTIES PHP_ZEND_EXTENSION TRUE)
  ```

## 11. PHP extensions

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
* `ext/lexbor`
* `ext/opcache`
* `ext/pcre`
* `ext/random`
* `ext/reflection`
* `ext/spl`
* `ext/standard`
* `ext/uri`

PHP extensions ecosystem also consists of the [PECL](https://pecl.php.net)
extensions. These can be installed with a separate tool `pecl`:

```sh
pecl install php_extension_name
```

PECL tool is a simple shell script wrapper around the PHP code as part of the
[pear-core](https://github.com/pear/pear-core/blob/master/scripts/pecl.sh)
repository.

> [!NOTE]
> `pecl` command-line script is also being replaced with a new tool
> [PIE](https://github.com/php/pie).

To build PHP extensions with CMake, a `CMakeLists.txt` file needs to be added to
the extension's source directory.

Example of `CMakeLists.txt` for PHP extensions can be found in the
`ext/skeleton` directory.

## 12. PHP SAPI (Server API) modules

PHP works through the concept of SAPI modules located in the `sapi` directory.

When running PHP on the command line, the cli SAPI module is used:

```sh
/sapi/cli/php -v
```

There are other SAPI modules located in the ecosystem:

* [frankenphp](https://github.com/php/frankenphp)
* [ngx-php](https://github.com/rryqszq4/ngx-php)
* ...

## 13. Generated files

During the build process, there are several files generated, some of which are
also tracked in the Git repository for a smoother workflow:

```sh
📂 <php-src>
└─📂 ext
  └─📂 date
    └─📂 lib
      └─📄 timelib_config.h      # Datetime library configuration header
  └─📂 mbstring
    └─📂 libmbfl
      └─📄 config.h              # The libmbfl configuration header
  └─📂 tokenizer
    ├─📄 tokenizer_data_stub.php # Generated by `ext/tokenizer/cmake/GenerateTokenizerData.cmake`
    └─📄 tokenizer_data.c        # Generated token types data file
└─📂 main
  ├─📄 internal_functions*.c     # Generated files with all internal functions
  ├─📄 config.w32.h              # Main configuration header for Windows
  ├─📄 debug_gdb_scripts.c       # Generated by `scripts/gdb/debug_gdb_scripts_gen.php`
  ├─📄 php_config.h              # Main configuration header for *nix systems
  └─📄 php_version.h             # Generated by release managers using `configure`
└─📂 scripts
  ├─📄 php-config                # PHP configuration helper script
  └─📄 phpize                    # Build configurator for PHP extensions
└─📂 win32                       # Windows build files
  ├─📄 cp_enc_map.c              # Generated from win32/cp_enc_map_gen.c
  └─📄 wsyslog.h                 # Generated by message compiler (mc.exe or windmc)
└─📂 Zend
  ├─📄 zend_config.h             # Zend Engine configuration header on *nix systems
  ├─📄 zend_config.w32.h         # Zend Engine configuration header on Windows
  ├─📄 zend_vm_execute.h         # Generated by `Zend/zend_vm_gen.php`
  ├─📄 zend_vm_opcodes.c         # Generated by `Zend/zend_vm_gen.php`
  └─📄 zend_vm_opcodes.h         # Generated by `Zend/zend_vm_gen.php`
```

### 13.1. Parser and lexer files

So-called parser files are generated with
[Bison](https://www.gnu.org/software/bison/) tool from `*.y` source files to C
source code and header files.

Lexer files are generated with [re2c](https://re2c.org/) tool from `*.l` and
`*.re` source files to C source code and header files.

To use Bison and re2c, the `FindBison` and `FindRE2C` modules find the tools
on the system, while `PHP/Bison.cmake` and `PHP/Re2c.cmake` utility modules
provide `php_bison()` and `php_re2c()` commands to generate the files.

Files related to Bison and re2c:

```sh
📂 <php-src>
└─📂 cmake
  └─📂 modules
    └─📂 PHP
      ├─📄 Bison.cmake              # For php_bison() and minimum Bison version
      └─📄 Re2c.cmake               # For php_re2c() and minimum re2c version
    ├─📄 FindBISON.cmake            # The Bison find module
    └─📄 FindRE2C.cmake             # The re2c find module
  └─📂 scripts
    └─📄 GenerateGrammar.cmake      # Command-line script for generating all
                                    # parser and lexer files
└─📂 ext
  └─📂 date
    └─📂 lib
      ├─📄 parse_date.c             # Generated with re2c 0.15.3
      └─📄 parse_iso_intervals.c    # Generated with re2c 0.15.3
  └─📂 ffi
    └─📄 ffi_parser.c               # Generated by https://github.com/dstogov/llk
  └─📂 json
    └─📂 cmake
      └─📄 GenerateGrammar.cmake    # Generates ext/json parser and lexer files
    ├─📄 json_parser.output         # Verbose report generated with Bison
    ├─📄 json_parser.tab.c          # Generated with Bison
    ├─📄 json_parser.tab.h          # Generated with Bison
    ├─📄 json_parser.y              # Parser source
    ├─📄 json_scanner.c             # Generated with re2c
    ├─📄 json_scanner.re            # Lexer source
    └─📄 php_json_scanner_defs.h    # Generated with re2c
  └─📂 pdo
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 pdo_sql_parser.c           # Generated with re2c
    └─📄 pdo_sql_parser.re          # Source for re2c
  └─📂 pdo_mysql
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 mysql_sql_parser.c         # Generated with re2c
    └─📄 mysql_sql_parser.re        # Source for re2c
  └─📂 pdo_pgsql
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 pgsql_sql_parser.c         # Generated with re2c
    └─📄 pgsql_sql_parser.re        # Source for re2c
  └─📂 pdo_sqlite
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 sqlite_sql_parser.c        # Generated with re2c
    └─📄 sqlite_sql_parser.re       # Source for re2c
  └─📂 phar
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 phar_path_check.c          # Generated with re2c
    └─📄 phar_path_check.re         # Source for re2c
  └─📂 standard
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 url_scanner_ex.c           # Generated with re2c
    ├─📄 url_scanner_ex.re          # Source for re2c
    ├─📄 var_unserializer.c         # Generated with re2c
    └─📄 var_unserializer.re        # Source for re2c
└─📂 sapi
  └─📂 phpdbg
    └─📂 cmake
      └─📄 GenerateGrammar.cmake
    ├─📄 phpdbg_lexer.c             # Generated with re2c
    ├─📄 phpdbg_lexer.l             # Source for re2c
    ├─📄 phpdbg_parser.c            # Generated with Bison
    ├─📄 phpdbg_parser.h            # Generated with Bison
    ├─📄 phpdbg_parser.y            # Source for Bison
    └─📄 phpdbg_parser.output       # Verbose report generated with Bison
└─📂 Zend
  └─📂 cmake
      └─📄 GenerateGrammar.cmake
  ├─📄 zend_ini_parser.c            # Generated with Bison
  ├─📄 zend_ini_parser.h            # Generated with Bison
  ├─📄 zend_ini_parser.output       # Verbose report generated with Bison
  ├─📄 zend_ini_parser.y            # Parser source
  ├─📄 zend_ini_scanner.c           # Generated with re2c
  ├─📄 zend_ini_scanner.l           # Lexer source
  ├─📄 zend_ini_scanner_defs.h      # Generated with re2c
  ├─📄 zend_language_parser.c       # Generated with Bison
  ├─📄 zend_language_parser.h       # Generated with Bison
  ├─📄 zend_language_parser.output  # Verbose report generated with Bison
  ├─📄 zend_language_parser.y       # Parser source
  ├─📄 zend_language_scanner_defs.h # Generated with re2c
  ├─📄 zend_language_scanner.c      # Generated with re2c
  └─📄 zend_language_scanner.l      # Lexer source
```

When building PHP from the released archives (`php-*.tar.gz`) from
[php.net](https://www.php.net/downloads.php) these files are already included in
the tarball itself so Bison and re2c are not required.

These are generated automatically when building PHP from the Git repository.

To generate these files manually apart from the main build:

```sh
cmake -P cmake/scripts/GenerateGrammar.cmake
```

## 14. Performance

When CMake is doing configuration phase, the profiling options can be used to do
build system performance analysis of CMake files.

```sh
cmake --profiling-output ./profile.json --profiling-format google-trace ../php-src
```

![CMake profiling](/docs/images/cmake-profiling.png)

## 15. Testing

PHP source code tests (`*.phpt` files) are written in PHP and are executed with
the `run-tests.php` script. CMake ships with a `ctest` utility that can run PHP
tests in a similar way.

To run all tests using CMake on the command line:

```sh
ctest --test-dir build-dir -j --progress --verbose
```

The optional `--progress` option displays a progress, `-j` option enables
running tests in parallel, and `--verbose` option outputs additional info to the
stdout. In PHP case the `--verbose` is added so the output of the
`run-tests.php` script is displayed.

Testing can be also specified in CMake presets so configuration can be coded and
shared using the `CMakePresets.json` file and its `testPresets` field.

```sh
ctest --preset all-enabled
```

Tests can be disabled with the
[`PHP_TESTING`](/docs/cmake/variables/PHP_TESTING.md)
configuration option:

```sh
cmake -B build-dir -DPHP_TESTING=OFF
```

## 16. Windows notes

### 16.1. Module-definition (.def) files

[Module-definition (.def) files](https://learn.microsoft.com/en-us/cpp/build/reference/module-definition-dot-def-files)
are added to certain php-src folders where linker needs them when building DLL.

In CMake they can be simply added to the target sources:

```cmake
target_sources(php_extension_name php_extension_name.def)
```

## 17. PHP installation

> [!CAUTION]
> **Before running the `cmake --install` command, be aware that files will be
> copied outside of the current build directory.**

When thinking about installing software, we often imagine downloading a package
and setting it up on the system, ready for immediate use.

PHP can be installed through various methods. On \*nix systems, this typically
involves using package managers (`apt install`, `dnf install`, `apk install`,
`pkg install`, `brew install`), or running all-in-one installers that provide a
preconfigured stack.

However, in the context of a build system, *installation* refers to the process
of preparing a directory structure with compiled files, making them ready for
direct use or for packaging.

During the installation phase, compiled binaries, dynamic libraries, header
files, \*nix man documentation pages, and other related files are copied into a
predefined directory structure. Some files may also be generated or modified
according to the final installation location, known as the
*installation prefix*.

It's important to note that this type of PHP installation is usually managed by
package managers, that handle this process through automated scripts.
Additionally, applying patches to tailor the PHP package to suit the specific
requirements of the target system is a common practice.

### 17.1. Installing PHP with CMake

Installing PHP with CMake can be done in the following way:

```sh
# Configuration and generation of build system files:
cmake -DCMAKE_INSTALL_PREFIX="/usr" -B php-build

# Build PHP in parallel:
cmake --build php-build -j

# Run tests using ctest utility:
ctest --progress -V --test-dir php-build

# Finally, copy built files to their system locations:
DESTDIR=/stage cmake --install php-build

# Or by using the --install-prefix configuration-phase option:
cmake --install-prefix /usr -B php-build
cmake --build php-build -j
ctest --progress -V --test-dir php-build
DESTDIR=/stage cmake --install php-build

# Alternatively, the --prefix installation-phase option can be used in certain
# packaging and installation workflows:
cmake -B php-build
cmake --build php-build -j
ctest --progress -V --test-dir php-build
DESTDIR=/stage cmake --install php-build --prefix /custom-location
```

> [!NOTE]
> The CMake [`DESTDIR`](https://cmake.org/cmake/help/latest/envvar/DESTDIR.html)
> environment variable behaves like the `INSTALL_ROOT` in PHP native
> Autotools-based build system.

* The [`CMAKE_INSTALL_PREFIX`](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html)
  variable is absolute path where to install the application.

To adjust the installation locations, the
[GNUInstallDirs](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
module is used to set additional `CMAKE_INSTALL_*` variables. These variables
are by default relative paths. When customized, they can be either relative or
absolute. When changed to absolute values the installation prefix will not be
taken into account. Here only those relevant to PHP are listed:

* `CMAKE_INSTALL_BINDIR`
* `CMAKE_INSTALL_SBINDIR`
* `CMAKE_INSTALL_SYSCONFDIR`
* `CMAKE_INSTALL_LOCALSTATEDIR`
* `CMAKE_INSTALL_RUNSTATEDIR`
* `CMAKE_INSTALL_LIBDIR`
* `CMAKE_INSTALL_INCLUDEDIR`
* `CMAKE_INSTALL_DATAROOTDIR`
* `CMAKE_INSTALL_DATADIR`
* `CMAKE_INSTALL_DOCDIR`
* `CMAKE_INSTALL_MANDIR`

PHP CMake-based build system specific installation cache variables:

* [`PHP_EXTENSION_DIR`](/docs/cmake/variables/PHP_EXTENSION_DIR.md)

  Path containing shared PHP extensions.

* [`PHP_INCLUDE_PREFIX`](/docs/cmake/variables/PHP_INCLUDE_PREFIX.md)

  The PHP include directory inside the `CMAKE_INSTALL_INCLUDEDIR`.
  Default: `php`

* [`PHP_LIB_PREFIX`](/docs/cmake/variables/PHP_LIB_PREFIX.md)

  The PHP directory inside the `CMAKE_INSTALL_LIBDIR`.
  Default: `php`

* [`PHP_PEAR_INSTALL_DIR`](/docs/cmake/variables/PHP_PEAR.md)

  The path where PEAR will be installed to.

* [`PHP_PEAR_TEMP_DIR`](/docs/cmake/variables/PHP_PEAR.md)

  Path where PEAR writes temporary files. Default: `/tmp/pear` on \*nix,
  `C:/temp/pear` on Windows.

### 17.2. Installation directory structure

PHP installation directory structure when using CMake:

```sh
📦 $ENV{DESTDIR}                      # 📦
└─📂 ${CMAKE_INSTALL_PREFIX}          # └─📂 /usr/local (Windows: C:/Program Files/${PROJECT_NAME})
  ├─📂 ${CMAKE_INSTALL_BINDIR}        #   ├─📂 bin
  └─📂 ${CMAKE_INSTALL_SYSCONFDIR}    #   └─📂 etc
    ├─📂 php-fpm.d                    #     ├─📂 php-fpm.d
    ├─📄 pear.conf                    #     ├─📄 pear.conf
    └─📄 php-fpm.conf.default         #     └─📄 php-fpm.conf.default
  └─📂 ${CMAKE_INSTALL_INCLUDEDIR}    #   └─📂 include
    └─📂 ${PHP_INCLUDE_PREFIX}        #     └─📂 php
      ├─📂 ext                        #       ├─📂 ext
      ├─📂 main                       #       ├─📂 main
      ├─📂 sapi                       #       ├─📂 sapi
      ├─📂 TSRM                       #       ├─📂 TSRM
      └─📂 Zend                       #       └─📂 Zend
  └─📂 ${CMAKE_INSTALL_LIBDIR}        #   └─📂 lib
    └─📂 cmake                        #     └─📂 cmake
      └─📂 PHP                        #       └─📂 PHP
        ├─📂 modules                  #         ├─📂 modules
        ├─📄 PHPConfig.cmake          #         ├─📄 PHPConfig.cmake
        └─📄 PHPConfigVersion.cmake   #         └─📄 PHPConfigVersion.cmake
    └─📂 cps                          #     └─📂 cps
      └─📂 PHP                        #       └─📂 PHP
        └─📄 PHP.cps                  #         └─📄 PHP.cps
    └─📂 ${PHP_LIB_PREFIX}            #     └─📂 php
      └─📂 build                      #       ├─📂 build
  └─📂 ${PHP_EXTENSION_DIR}           #       └─📂 20230901-zts-Debug...
    └─📂 pkgconfig                    #     └─📂 pkgconfig
      ├─📄 php-embed.pc               #       ├─📄 php-embed.pc
      └─📄 php.pc                     #       └─📄 php.pc
  ├─📂 ${CMAKE_INSTALL_SBINDIR}       #   ├─📂 sbin
  └─📂 ${CMAKE_INSTALL_DATAROOTDIR}   #   └─📂 share
    └─📂 ${CMAKE_INSTALL_DOCDIR}      #     └─📂 doc
      └─📂 PHP                        #       └─📂 PHP
    └─📂 ${CMAKE_INSTALL_MANDIR}      #     └─📂 man
      ├─📂 man1                       #       ├─📂 man1
      └─📂 man8                       #       └─📂 man8
  └─📂 ${CMAKE_INSTALL_DATADIR}       #   └─📂 (share)
    └─📂 php                          #     └─📂 php
      └─📂 fpm                        #       └─📂 fpm
  ├─📂 ${PHP_PEAR_INSTALL_DIR}        #     └─📂 pear (default: share/pear)
  └─📂 ${CMAKE_INSTALL_LOCALSTATEDIR} #   └─📂 var
    └─📂 log                          #     └─📂 log
  └─📂 ${CMAKE_INSTALL_RUNSTATEDIR}   #   └─📂 var/run
└─📂 ${PHP_PEAR_TEMP_DIR}             # └─📂 /tmp/pear (Windows: C:/temp/pear)
  ├─📂 cache                          #   ├─📂 cache
  ├─📂 download                       #   ├─📂 download
  └─📂 temp                           #   └─📂 temp
```

> [!NOTE]
> The CMake [GNUInstallDirs](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html#special-cases)
> module also adjusts some `CMAKE_INSTALL_*` variables in
> [special cases](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html#special-cases)
> according to GNU standards. See also
> [GNU directory variables](https://www.gnu.org/prep/standards/html_node/Directory-Variables.html)
> for more info.

Instead of setting the installation prefix at the configuration phase using
`CMAKE_INSTALL_PREFIX` variable or `--install-prefix` option, there is
also `installDir` field which can be set in the `CMakePresets.json` or
`CMakeUserPresets.json` file.

Example `CMakeUserPresets.json` file, which can be added to the PHP source code
root directory:

```json
{
  "version": 4,
  "configurePresets": [
    {
      "name": "acme-php",
      "inherits": "all-enabled",
      "displayName": "Acme PHP configuration",
      "description": "Customized PHP build",
      "installDir": "/usr",
      "cacheVariables": {
        "CMAKE_INSTALL_BINDIR": "home/user/.local/bin",
        "PHP_BUILD_SYSTEM": "Acme Linux",
        "PHP_BUILD_PROVIDER": "Acme",
        "PHP_BUILD_COMPILER": "GCC",
        "PHP_BUILD_ARCH": "x86_64",
        "PHP_VERSION_LABEL": "-acme"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "acme-php",
      "configurePreset": "acme-php"
    }
  ],
  "testPresets": [
    {
      "name": "acme-php",
      "configurePreset": "acme-php",
      "output": {"verbosity": "verbose"}
    }
  ]
}
```

Above file *inherits* from the `all-enabled` configuration preset of the default
`CMakePresets.json` file and adjusts the PHP installation.

To build and install using the new preset:

```sh
cmake --preset acme-php
cmake --build --preset acme-php -j
ctest --preset acme-php
cmake --install .
```

### 17.3. Installation components

Installation components are groups of CMake's `install()` commands, where
`COMPONENT` argument is specified. They provide installing only certain parts of
the project. For example:

```cmake
# CMakeLists.txt

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/PHPConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/PHPConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  COMPONENT php-development
)
```

Available installation components can be listed after project is configured
with:

```sh
cmake --build build-dir --target list_install_components
```

To install only specific component:

```sh
cmake --install build-dir --component php-development
```
