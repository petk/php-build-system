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
* [7. Interface libraries](#7-interface-libraries)
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
📂 <php-src>
└─📂 cmake                     # CMake-based PHP build system files
  └─📂 modules                 # Project-specific CMake modules
    ├─📂 PHP                   # PHP utility CMake modules
    └─📄 Find*.cmake           # Find modules that support the find_package()
  ├─📂 platforms               # Platform-specific configuration
  ├─📂 presets                 # Presets included in CMakePresets.json
  ├─📂 scripts                 # Various CMake command-line scripts
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
> jobs is often the number of available logical CPU cores (a.k.a threads) of
> the build machine and can be also automatically calculated using the
> `$(nproc)` on Linux, or `$(sysctl -n hw.ncpu)` on macOS and BSD-based systems.
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
version available on the operating system. The minimum required CMake version in
this repository is **3.29**.

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
  * `if(PATH_EQUAL)`
* 3.25
  * `block()` command
  * New `try_run` signature
  * `cmake_language()` keyword `GET_MESSAGE_LOG_LEVEL`
  * `return()` keyword `PROPAGATE`
* 3.27
  * `COMPILE_ONLY` generator expression
  * `INSTALL_PREFIX` generator expression in `install(CODE)`
  * `$<LIST:FILTER,list,...>` generator expression
  * `$<LIST:SORT,list[,...]>` generator expression
  * `<PACKAGENAME>_ROOT` variables in addition to `<PackageName>_ROOT`
* 3.26
  * `BZIP2_VERSION`
  * `ASM_MARMASM` language support
* 3.29
  * `CMAKE_LINKER_TYPE`
  * `CMAKE_<LANG>_COMPILER_LINKER_VERSION`
  * `if(IS_EXECUTABLE)`
* 3.31
  * `add_custom_command()` keyword `CODEGEN`
* 4.1
  * `CMAKE_<LANG>_COMPILER_ARCHITECTURE_ID` variable.

CMake versions scheme across the systems is available at
[pkgs.org](https://pkgs.org/download/cmake).

> [!TIP]
> While the CMake version on some systems may be outdated, there are various
> options available to install the latest version. There are binary
> [CMake](https://cmake.org/download/) downloads available for the most used
> platforms, there is a [`snap`](https://snapcraft.io/cmake) package, and
> [APT repository](https://apt.kitware.com/) for Debian-based distributions.

## 7. Interface libraries

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

## 8. PHP CMake modules

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

* [PHP/AddCustomCommand](/docs/cmake/modules/PHP/AddCustomCommand.md)
* [PHP/Bison](/docs/cmake/modules/PHP/Bison.md)
* [PHP/CheckAttribute](/docs/cmake/modules/PHP/CheckAttribute.md)
* [PHP/CheckBuiltin](/docs/cmake/modules/PHP/CheckBuiltin.md)
* [PHP/CheckCompilerFlag](/docs/cmake/modules/PHP/CheckCompilerFlag.md)
* [PHP/CheckSysMacros](/docs/cmake/modules/PHP/CheckSysMacros.md)
* [PHP/Install](/docs/cmake/modules/PHP/Install.md)
* [PHP/Re2c](/docs/cmake/modules/PHP/Re2c.md)
* [PHP/SearchLibraries](/docs/cmake/modules/PHP/SearchLibraries.md)
* [PHP/Set](/docs/cmake/modules/PHP/Set.md)
* [PHP/StandardLibrary](/docs/cmake/modules/PHP/StandardLibrary.md)
* [PHP/SystemExtensions](/docs/cmake/modules/PHP/SystemExtensions.md)
* [PHP/VerboseLink](/docs/cmake/modules/PHP/VerboseLink.md)

## 9. Custom CMake properties

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

* PHP_EXTENSION

  Target property that designates that the CMake target is a PHP extension.

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

> [!NOTE]
> `pecl` command-line script is also being replaced with a new tool
> [PIE](https://github.com/php/pie).

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

There are other SAPI modules located in the ecosystem:

* [frankenphp](https://github.com/dunglas/frankenphp)
* [ngx-php](https://github.com/rryqszq4/ngx-php)
* ...

## 12. Generated files

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

### 12.1. Parser and lexer files

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
