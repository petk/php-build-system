# PHP build system configuration

## Index

* [1. CMake presets](#1-cmake-presets)
* [2. CMake configuration](#2-cmake-configuration)
* [3. PHP configuration](#3-php-configuration)
* [4. Zend Engine configuration](#4-zend-engine-configuration)
* [5. PHP SAPI modules configuration](#5-php-sapi-modules-configuration)
* [6. PHP extensions configuration](#6-php-extensions-configuration)
* [7. CMake GUI](#7-cmake-gui)
* [8. Command-line interface ccmake](#8-command-line-interface-ccmake)
* [9. Configuration options mapping: Autotools, Windows JScript, and CMake](#9-configuration-options-mapping-autotools-windows-jscript-and-cmake)

Build configuration can be passed on the command line at the configuration
phase with the `-D` options:

```sh
cmake -DCMAKE_FOO=ON -DPHP_BAR=ON -DPHP_EXT_NAME=ON ... -S php-src -B php-build
```

The `-LH` and `-LAH` command-line options list all available configuration cache
variables with help texts after CMake configures cache:

```sh
# List configuration
cmake -LH -S php-src -B php-build

# List also advanced cache variables
cmake -LAH -S php-src -B php-build

# Another option is to use ccmake or cmake-gui tool
ccmake -S php-src -B php-build
```

To override the paths to dependencies, for example, when using a manual
installation of a library, there are two main options to consider:

* `CMAKE_PREFIX_PATH="DIR_1;DIR_2;..."`

  A semicolon separated list of additional directories where packages can be
  found by `find_*()` commands.

  For example, to pass manual paths for iconv and SQLite3 libraries:

  ```sh
  cmake -DCMAKE_PREFIX_PATH="/path/to/libiconv;/path/to/sqlite3" -S php-src -B php-build
  ```

* `<PACKAGENAME>_ROOT` variables

  Path where to look for `PackageName`, when calling the
  `find_package(<PackageName> ...)` command.

  ```sh
  cmake -DICONV_ROOT=/path/to/libiconv -DSQLITE3_ROOT=/path/to/sqlite3 -S php-src -B php-build
  ```

## 1. CMake presets

Instead of manually passing variables on the command line with
`cmake -DFOO=BAR ...`, configuration options can be simply stored and shared in
a JSON file `CMakePresets.json` at the project root directory.

The [CMakePresets.json](/cmake/CMakePresets.json) file incorporates some common
build configuration for development, continuous integration, bug reporting, etc.
Additional configure presets are included from the `cmake/presets` directory.

To use the CMake presets:

```sh
# List all available configure presets
cmake --list-presets

# Configure project; replace "default" with the name of the "configurePresets"
cmake --preset default

# Build project using the "default" build preset in parallel (-j)
cmake --build --preset default -j
```

Custom local build configuration can be also stored in a Git-ignored file
`CMakeUserPresets.json` intended to override the defaults in
`CMakePresets.json`.

CMake presets have been available since CMake 3.19, and depending on the
`version` JSON field, the minimum required CMake version may vary based on the
used JSON scheme.

## 2. CMake configuration

Some useful overridable configuration options built into CMake itself. All these
`CMAKE_*` and `BUILD_SHARED_LIBS` variables are also documented in the CMake
documentation.

* `CMAKE_EXPORT_COMPILE_COMMANDS=ON|OFF`

  Default: `OFF`

  Create compilation database file `compile_commands.json` during generation.
  Various other development tools can then use it. For example, `clang-check`.

* `CMAKE_INTERPROCEDURAL_OPTIMIZATION=ON|OFF`

  Default: `ON`

  Run link-time optimizer on all targets if interprocedural optimization (IPO)
  is supported by the compiler and PHP code.

  * `CMAKE_INTERPROCEDURAL_OPTIMIZATION_<CONFIG>=ON|OFF`

    Enable or disable IPO based on the build type (`CMAKE_BUILD_TYPE`). For
    example, to disable IPO for the `Debug` build type set
    `CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG` to `OFF`.

* `CMAKE_LIBRARY_PATH`

  Default: empty

  Specify additional semicolon-separated paths where to look for system
  libraries if default locations searched by CMake is not sufficient in some
  build case scenario.

* `CMAKE_LINKER_TYPE` (CMake 3.29+)

  Default: empty

  Specify which linker will be used for the link step.

  ```sh
  # For example, to use the mold linker:
  cmake -S php-src -B php-build -DCMAKE_LINKER_TYPE=MOLD
  ```

* `CMAKE_MESSAGE_CONTEXT_SHOW=ON|OFF`

  Default: `OFF`

  Show/hide context in configuration log ([ext/foo] Checking for...).

* `BUILD_SHARED_LIBS=ON|OFF`

  Default: `OFF`

  Build all enabled PHP extensions as shared libraries.

* `CMAKE_SKIP_RPATH=ON|OFF`

  Default: `OFF`

  Controls whether to add additional runtime library search paths (runpaths or
  rpath) to executables in build directory and installation directory. These are
  passed in form of `-Wl,-rpath,/additional/path/to/library` at build time.

  See the RUNPATH in the executable:

  ```sh
  objdump -x ./php-src/sapi/cli/php | grep 'R.*PATH'
  ```

  * `CMAKE_SKIP_BUILD_RPATH=ON|OFF`

    Default: `OFF`

    Disable runtime library search paths (rpath) in build directory executables.

  * `CMAKE_SKIP_INSTALL_RPATH=ON|OFF`

    Default: `OFF`

    Disable runtime library search paths (rpath) in installation directory
    executables.

## 3. PHP configuration

* [`PHP_ADDRESS_SANITIZER`](/docs/cmake/variables/_PHP_ADDRESS_SANITIZER.md)
* [`PHP_BUILD_ARCH`](/docs/cmake/variables/PHP_BUILD_ARCH.md)
* [`PHP_BUILD_COMPILER`](/docs/cmake/variables/PHP_BUILD_COMPILER.md)
* [`PHP_BUILD_PROVIDER`](/docs/cmake/variables/PHP_BUILD_PROVIDER.md)
* [`PHP_CCACHE`](/docs/cmake/variables/PHP_CCACHE.md)
* [`PHP_CONFIG_FILE_PATH`](/docs/cmake/variables/PHP_CONFIG_FILE_PATH.md)
* [`PHP_CONFIG_FILE_SCAN_DIR`](/docs/cmake/variables/PHP_CONFIG_FILE_SCAN_DIR.md)
* [`PHP_DEFAULT_SHORT_OPEN_TAG`](/docs/cmake/variables/PHP_DEFAULT_SHORT_OPEN_TAG.md)
* [`PHP_DMALLOC`](/docs/cmake/variables/PHP_DMALLOC.md)
* [`PHP_DTRACE`](/docs/cmake/variables/PHP_DTRACE.md)
* [`PHP_GCOV`](/docs/cmake/variables/PHP_GCOV.md)
* [`PHP_MEMORY_SANITIZER`](/docs/cmake/variables/_PHP_MEMORY_SANITIZER.md)
* [`PHP_EXTENSION_DIR`](/docs/cmake/variables/PHP_EXTENSION_DIR.md)
* [`PHP_FD_SETSIZE`](/docs/cmake/variables/PHP_FD_SETSIZE.md)
* [`PHP_INCLUDE_PREFIX`](/docs/cmake/variables/PHP_INCLUDE_PREFIX.md)
* [`PHP_IPV6`](/docs/cmake/variables/PHP_IPV6.md)
* [`PHP_LIBGCC`](/docs/cmake/variables/PHP_LIBGCC.md)
* [`PHP_RE2C_COMPUTED_GOTOS`](/docs/cmake/variables/PHP_RE2C_COMPUTED_GOTOS.md)
* [`PHP_SIGCHILD`](/docs/cmake/variables/PHP_SIGCHILD.md)
* [`PHP_SYSTEM_GLOB`](/docs/cmake/variables/PHP_SYSTEM_GLOB.md)
* [`PHP_THREAD_SAFETY`](/docs/cmake/variables/PHP_THREAD_SAFETY.md)
* [`PHP_UNDEFINED_SANITIZER`](/docs/variables/_PHP_UNDEFINED_SANITIZER.md)
* [`PHP_USE_RTLD_NOW`](/docs/cmake/variables/PHP_USE_RTLD_NOW.md)
* [`PHP_VALGRIND`](/docs/cmake/variables/PHP_VALGRIND.md)
* [`SED_EXECUTABLE`](/docs/cmake/variables/SED_EXECUTABLE.md)

* [`PEAR`](/docs/cmake/pear.md)

## 4. Zend Engine configuration

* [`ZEND_FIBER_ASM`](/docs/cmake/variables/ZEND_FIBER_ASM.md)
* [`ZEND_GLOBAL_REGISTER_VARIABLES`](/docs/cmake/variables/ZEND_GLOBAL_REGISTER_VARIABLES.md)
* [`ZEND_MAX_EXECUTION_TIMERS`](/docs/cmake/variables/ZEND_MAX_EXECUTION_TIMERS.md)
* [`ZEND_SIGNALS`](/docs/cmake/variables/ZEND_SIGNALS.md)

## 5. PHP SAPI modules configuration

* [`apache2handler`](/docs/cmake/sapi/apache2handler.md)
* [`cgi`](/docs/cmake/sapi/cgi.md)
* [`cli`](/docs/cmake/sapi/cli.md)
* [`embed`](/docs/cmake/sapi/embed.md)
* [`fpm`](/docs/cmake/sapi/fpm.md)
* [`fuzzer`](/docs/cmake/sapi/fuzzer.md)
* [`litespeed`](/docs/cmake/sapi/litespeed.md)
* [`phpdbg`](/docs/cmake/sapi/phpdbg.md)

## 6. PHP extensions configuration

* [`bcmath`](/docs/cmake/ext/bcmath.md)
* [`bz2`](/docs/cmake/ext/bz2.md)
* [`calendar`](/docs/cmake/ext/calendar.md)
* [`com_dotnet`](/docs/cmake/ext/com_dotnet.md)
* [`ctype`](/docs/cmake/ext/ctype.md)
* [`curl`](/docs/cmake/ext/curl.md)
* [`date`](/docs/cmake/ext/date.md)
* [`dba`](/docs/cmake/ext/dba.md)
* [`dl_test`](/docs/cmake/ext/dl_test.md)
* [`dom`](/docs/cmake/ext/dom.md)
* [`enchant`](/docs/cmake/ext/enchant.md)
* [`exif`](/docs/cmake/ext/exif.md)
* [`ffi`](/docs/cmake/ext/ffi.md)
* [`fileinfo`](/docs/cmake/ext/fileinfo.md)
* [`filter`](/docs/cmake/ext/filter.md)
* [`ftp`](/docs/cmake/ext/ftp.md)
* [`gd`](/docs/cmake/ext/gd.md)
* [`gettext`](/docs/cmake/ext/gettext.md)
* [`gmp`](/docs/cmake/ext/gmp.md)
* [`hash`](/docs/cmake/ext/hash.md)
* [`iconv`](/docs/cmake/ext/iconv.md)
* [`intl`](/docs/cmake/ext/intl.md)
* [`json`](/docs/cmake/ext/json.md)
* [`ldap`](/docs/cmake/ext/ldap.md)
* [`libxml`](/docs/cmake/ext/libxml.md)
* [`mbstring`](/docs/cmake/ext/mbstring.md)
* [`mysqli`](/docs/cmake/ext/mysqli.md)
* [`mysqlnd`](/docs/cmake/ext/mysqlnd.md)
* [`odbc`](/docs/cmake/ext/odbc.md)
* [`opcache`](/docs/cmake/ext/opcache.md)
* [`openssl`](/docs/cmake/ext/openssl.md)
* [`pcntl`](/docs/cmake/ext/pcntl.md)
* [`pcre`](/docs/cmake/ext/pcre.md)
* [`pdo`](/docs/cmake/ext/pdo.md)
* [`pdo_dblib`](/docs/cmake/ext/pdo_dblib.md)
* [`pdo_firebird`](/docs/cmake/ext/pdo_firebird.md)
* [`pdo_mysql`](/docs/cmake/ext/pdo_mysql.md)
* [`pdo_odbc`](/docs/cmake/ext/pdo_odbc.md)
* [`pdo_pgsql`](/docs/cmake/ext/pdo_pgsql.md)
* [`pdo_sqlite`](/docs/cmake/ext/pdo_sqlite.md)
* [`pgsql`](/docs/cmake/ext/pgsql.md)
* [`phar`](/docs/cmake/ext/phar.md)
* [`posix`](/docs/cmake/ext/posix.md)
* [`random`](/docs/cmake/ext/random.md)
* [`readline`](/docs/cmake/ext/readline.md)
* [`reflection`](/docs/cmake/ext/reflection.md)
* [`session`](/docs/cmake/ext/session.md)
* [`shmop`](/docs/cmake/ext/shmop.md)
* [`simplexml`](/docs/cmake/ext/simplexml.md)
* [`skeleton`](/docs/cmake/ext/skeleton.md)
* [`snmp`](/docs/cmake/ext/snmp.md)
* [`soap`](/docs/cmake/ext/soap.md)
* [`sockets`](/docs/cmake/ext/sockets.md)
* [`sodium`](/docs/cmake/ext/sodium.md)
* [`spl`](/docs/cmake/ext/spl.md)
* [`sqlite3`](/docs/cmake/ext/sqlite3.md)
* [`standard`](/docs/cmake/ext/standard.md)
* [`sysvmsg`](/docs/cmake/ext/sysvmsg.md)
* [`sysvsem`](/docs/cmake/ext/sysvsem.md)
* [`sysvshm`](/docs/cmake/ext/sysvshm.md)
* [`tidy`](/docs/cmake/ext/tidy.md)
* [`tokenizer`](/docs/cmake/ext/tokenizer.md)
* [`xml`](/docs/cmake/ext/xml.md)
* [`xmlreader`](/docs/cmake/ext/xmlreader.md)
* [`xmlwriter`](/docs/cmake/ext/xmlwriter.md)
* [`xsl`](/docs/cmake/ext/xsl.md)
* [`zend_test`](/docs/cmake/ext/zend_test.md)
* [`zip`](/docs/cmake/ext/zip.md)
* [`zlib`](/docs/cmake/ext/zlib.md)

## 7. CMake GUI

With CMake there comes also a basic graphical user interface to configure and
generate the build system.

Inside a CMake project, run:

```sh
cmake-gui .
```

![CMake GUI](/docs/images/cmake-gui.png)

Here the build configuration can be done, such as enabling the PHP extensions,
adjusting the build options and similar.

CMake GUI makes it simpler to see available build options and settings and it
also conveniently hides and sets the dependent options. For example, if some PHP
extension provides multiple configuration options and it is disabled, the
dependent options won't be displayed after configuration.

![CMake GUI setup](/docs/images/cmake-gui-2-setup.png)

After setting up, press the `Configure` button to start the configuration phase
and prepare the build configuration. The `Generate` buttons can then generate
the chosen build system.

![CMake GUI configuration](/docs/images/cmake-gui-3.png)

GUI is only meant to configure and generate the build in user-friendly way.
Building the sources into binaries can be then done using the command line or an
IDE.

```sh
cmake --build --preset default
```

## 8. Command-line interface ccmake

The CMake curses interface (`ccmake`) is a command-line GUI, similar to the
CMake GUI, that simplifies the project configuration process in an intuitive and
straightforward manner.

```sh
# Run ccmake:
ccmake -S source-directory -B build-directory

# For in-source builds:
ccmake .
```

![The ccmake GUI](/docs/images/ccmake.png)

* `c` key will run the configuration step
* `g` key will run the generation step (you might need to press `c` again)

Much like the CMake GUI, the build step is executed on the command line
afterward.

```sh
# Build the project sources from the specified build directory:
cmake --build build-directory -j
```

`ccmake` does not support presets but can be utilized for simpler configurations
during development and for similar workflows.

## 9. Configuration options mapping: Autotools, Windows JScript, and CMake

A list of Autoconf `configure` command-line configuration options, Windows
`configure.bat` options and their CMake alternatives.

<table>
  <thead>
    <tr>
      <th>configure</th>
      <th>configure.bat</th>
      <th>CMake</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th colspan="4">PHP configuration</td>
    </tr>
    <tr>
      <td>--disable-re2c-cgoto</td>
      <td>N/A</td>
      <td>PHP_RE2C_COMPUTED_GOTOS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-re2c-cgoto</td>
      <td>N/A</td>
      <td>PHP_RE2C_COMPUTED_GOTOS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-debug</td>
      <td>--disable-debug</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-debug</td>
      <td>--enable-debug</td>
      <td>
        Single configuration generators: <code>CMAKE_BUILD_TYPE=Debug</code><br>
        Multi configuration generators: <code>cmake --build dir --config Debug</code>
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-debug-assertions</td>
      <td>--disable-debug-pack</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-debug-assertions</td>
      <td>--enable-debug-pack</td>
      <td>
        Single configuration generators: <code>CMAKE_BUILD_TYPE=DebugAssertions</code><br>
        Multi configuration generators: <code>cmake --build dir --config DebugAssertions</code>
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sigchild</td>
      <td>N/A</td>
      <td>PHP_SIGCHILD=OFF</td>
      <td>default (not available on Windows)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sigchild</td>
      <td>N/A</td>
      <td>PHP_SIGCHILD=ON</td>
      <td>(not available on Windows)</td>
    </tr>
    <tr>
      <td>--enable-ipv6</td>
      <td>--enable-ipv6</td>
      <td>PHP_IPV6=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-ipv6</td>
      <td>--disable-ipv6</td>
      <td>PHP_IPV6=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-rtld-now</td>
      <td>N/A</td>
      <td>PHP_USE_RTLD_NOW=OFF</td>
      <td>default (not available on Windows)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-rtld-now</td>
      <td>N/A</td>
      <td>PHP_USE_RTLD_NOW=ON</td>
      <td>(not available on Windows)</td>
    </tr>
    <tr>
      <td>--enable-short-tags</td>
      <td>N/A</td>
      <td>PHP_DEFAULT_SHORT_OPEN_TAG=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-short-tags</td>
      <td>N/A</td>
      <td>PHP_DEFAULT_SHORT_OPEN_TAG=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zts</td>
      <td>--disable-zts</td>
      <td>PHP_THREAD_SAFETY=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-zts</td>
      <td>--enable-zts</td>
      <td>PHP_THREAD_SAFETY=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dtrace</td>
      <td>N/A</td>
      <td>PHP_DTRACE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dtrace</td>
      <td>N/A</td>
      <td>
        PHP_DTRACE=ON<br>
        [DTRACE_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fd-setsize</td>
      <td>--disable-fd-setsize</td>
      <td>PHP_FD_SETSIZE=""</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-fd-setsize=NUM</td>
      <td>--enable-fd-setsize=256</td>
      <td>PHP_FD_SETSIZE=NUM</td>
      <td>default on Windows</td>
    </tr>
    <tr>
      <td>--without-valgrind</td>
      <td>N/A</td>
      <td>PHP_VALGRIND=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-valgrind<br>
        &emsp;[VALGRIND_CFLAGS=...]<br>
        &emsp;[VALGRIND_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_VALGRIND=ON<br>
        [VALGRIND_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--with-libdir=NAME</td>
      <td>N/A</td>
      <td>CMAKE_LIBRARY_PATH=NAME</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-layout=PHP|GNU</td>
      <td>N/A</td>
      <td>N/A</td>
      <td>Autotools default: PHP</td>
    </tr>
    <tr>
      <td>--disable-werror</td>
      <td>N/A</td>
      <td>--compile-no-warning-as-error</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-werror</td>
      <td>CFLAGS=/WX</td>
      <td>CMAKE_COMPILE_WARNING_AS_ERROR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-memory-sanitizer</td>
      <td></td>
      <td>PHP_MEMORY_SANITIZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-memory-sanitizer</td>
      <td></td>
      <td>PHP_MEMORY_SANITIZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-address-sanitizer</td>
      <td></td>
      <td>PHP_ADDRESS_SANITIZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-address-sanitizer</td>
      <td></td>
      <td>PHP_ADDRESS_SANITIZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-undefined-sanitizer</td>
      <td></td>
      <td>PHP_UNDEFINED_SANITIZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-undefined-sanitizer</td>
      <td></td>
      <td>PHP_UNDEFINED_SANITIZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dmalloc</td>
      <td>N/A</td>
      <td>PHP_DMALLOC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dmalloc</td>
      <td>N/A</td>
      <td>
        PHP_DMALLOC=ON<br>
        [DMALLOC_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--without-config-file-scan-dir</td>
      <td>--without-config-file-scan-dir</td>
      <td>PHP_CONFIG_FILE_SCAN_DIR=""</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-config-file-scan-dir=DIR</td>
      <td>--with-config-file-scan-dir=DIR</td>
      <td>PHP_CONFIG_FILE_SCAN_DIR=DIR</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-config-file-path</td>
      <td>N/A</td>
      <td>PHP_CONFIG_FILE_PATH=""</td>
      <td>default, *nix only</td>
    </tr>
    <tr>
      <td>&emsp;--with-config-file-path=PATH</td>
      <td>N/A</td>
      <td>PHP_CONFIG_FILE_PATH=PATH</td>
      <td>*nix only</td>
    </tr>
    <tr>
      <td>--disable-gcov</td>
      <td>N/A</td>
      <td>PHP_GCOV=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-gcov</td>
      <td>N/A</td>
      <td>
        PHP_GCOV=ON<br>
        [GCOV_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-rpath</td>
      <td>N/A</td>
      <td>
        CMAKE_SKIP_RPATH=OFF<br>
        CMAKE_SKIP_INSTALL_RPATH=OFF<br>
        CMAKE_SKIP_BUILD_RPATH=OFF
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-rpath</td>
      <td>N/A</td>
      <td>
        CMAKE_SKIP_RPATH=ON<br>
        or CMAKE_SKIP_INSTALL_RPATH=ON<br>
        and/or CMAKE_SKIP_BUILD_RPATH=ON
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-libgcc</td>
      <td>N/A</td>
      <td>PHP_LIBGCC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-libgcc</td>
      <td>N/A</td>
      <td>PHP_LIBGCC=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-system-glob</td>
      <td>N/A</td>
      <td>PHP_SYSTEM_GLOB=OFF</td>
      <td>default, PHP &gt;= 8.5</td>
    </tr>
    <tr>
      <td>&emsp;--enable-system-glob</td>
      <td>N/A</td>
      <td>PHP_SYSTEM_GLOB=ON</td>
      <td>PHP &gt;= 8.5</td>
    </tr>
    <tr>
      <td>--enable-all</td>
      <td>--enable-snapshot-build</td>
      <td>Use <code>cmake --preset all-enabled</code></td>
      <td>Enables all extensions and some additional configuration</td>
    </tr>
    <tr>
      <td>--disable-all</td>
      <td>--disable-snapshot-build</td>
      <td>Use <code>cmake --preset all-disabled</code></td>
      <td>Disables all extensions and some additional configuration</td>
    </tr>
    <tr>
      <th colspan="4">Zend Engine configuration</td>
    </tr>
    <tr>
      <td>--enable-gcc-global-regs</td>
      <td>N/A</td>
      <td>ZEND_GLOBAL_REGISTER_VARIABLES=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-gcc-global-regs</td>
      <td>N/A</td>
      <td>ZEND_GLOBAL_REGISTER_VARIABLES=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fiber-asm</td>
      <td>N/A</td>
      <td>ZEND_FIBER_ASM=ON</td>
      <td>default, *nix only</td>
    </tr>
    <tr>
      <td>&emsp;--disable-fiber-asm</td>
      <td>N/A</td>
      <td>ZEND_FIBER_ASM=OFF</td>
      <td>*nix only</td>
    </tr>
    <tr>
      <td>--enable-zend-signals</td>
      <td>N/A</td>
      <td>ZEND_SIGNALS=ON</td>
      <td>default, *nix only</td>
    </tr>
    <tr>
      <td>&emsp;--disable-zend-signals</td>
      <td>N/A</td>
      <td>ZEND_SIGNALS=OFF</td>
      <td>*nix only</td>
    </tr>
    <tr>
      <td>--disable-zend-max-execution-timers</td>
      <td>N/A</td>
      <td>ZEND_MAX_EXECUTION_TIMERS=OFF</td>
      <td>default, *nix only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-zend-max-execution-timers</td>
      <td>N/A</td>
      <td>ZEND_MAX_EXECUTION_TIMERS=ON</td>
      <td>*nix only</td>
    </tr>
    <tr>
      <th colspan="4">PHP SAPI modules configuration</th>
    </tr>
    <tr>
      <td>--without-apxs2</td>
      <td>
        --disable-apache2handler or<br>
        --disable-apache2-4handler
      </td>
      <td>PHP_SAPI_APACHE2HANDLER=OFF</td>
      <td>
        default, in PHP >= 8.4 <code>--disable-apache2handler</code> is for
        Apache 2.4 and not Apache 2.0 anymore
      </td>
    </tr>
    <tr>
      <td>&emsp;--with-apxs2[=PATH_TO_APXS]</td>
      <td>
        --enable-apache2handler or<br>
        --enable-apache2-4handler
      </td>
      <td>
        PHP_SAPI_APACHE2HANDLER=ON<br>
        [APACHE_ROOT=PATH_TO_APACHE]<br>
        [Apache_APXS_EXECUTABLE=PATH_TO_APXS]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--disable-apache2handler</td>
      <td>N/A</td>
      <td>default, in PHP <= 8.3 this was for Apache 2.0</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-apache2handler</td>
      <td>N/A</td>
      <td>in PHP <= 8.3 this was for Apache 2.0</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--disable-apache2-2handler</td>
      <td>N/A</td>
      <td>default, removed since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-apache2-2handler</td>
      <td>N/A</td>
      <td>removed since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>--enable-cgi</td>
      <td>--enable-cgi</td>
      <td>PHP_SAPI_CGI=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-cgi</td>
      <td>--disable-cgi</td>
      <td>PHP_SAPI_CGI=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-cli</td>
      <td>--enable-cli</td>
      <td>PHP_SAPI_CLI=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-cli</td>
      <td>--disable-cli</td>
      <td>PHP_SAPI_CLI=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--disable-cli-win32</td>
      <td>PHP_SAPI_CLI_WIN_NO_CONSOLE=OFF</td>
      <td>default; Windows only</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-cli-win32</td>
      <td>PHP_SAPI_CLI_WIN_NO_CONSOLE=ON</td>
      <td>Windows only</td>
    </tr>
    <tr>
      <td>--disable-embed</td>
      <td>--disable-embed</td>
      <td>PHP_SAPI_EMBED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-embed</td>
      <td>--enable-embed</td>
      <td>PHP_SAPI_EMBED=ON</td>
      <td>will be build as shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-embed=shared</td>
      <td>N/A</td>
      <td>
        PHP_SAPI_EMBED=ON<br>
        PHP_SAPI_EMBED_SHARED=ON
      </td>
      <td>will be build as shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-embed=static</td>
      <td>--enable-embed</td>
      <td>
        PHP_SAPI_EMBED=ON<br>
        PHP_SAPI_EMBED_SHARED=OFF
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fpm</td>
      <td>N/A</td>
      <td>PHP_SAPI_FPM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-fpm</td>
      <td>N/A</td>
      <td>PHP_SAPI_FPM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;[--with-fpm-user=USER]</td>
      <td>N/A</td>
      <td>[PHP_SAPI_FPM_USER=USER]</td>
      <td>default: nobody</td>
    </tr>
    <tr>
      <td>&emsp;[--with-fpm-group=GROUP]</td>
      <td>N/A</td>
      <td>[PHP_SAPI_FPM_GROUP=GROUP]</td>
      <td>default: nobody</td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-systemd</td>
      <td>N/A</td>
      <td>PHP_SAPI_FPM_SYSTEMD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-fpm-systemd<br>
        &emsp;[SYSTEMD_CFLAGS=...]<br>
        &emsp;[SYSTEMD_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_SAPI_FPM_SYSTEMD=ON<br>
        [SYSTEMD_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-acl</td>
      <td>N/A</td>
      <td>PHP_SAPI_FPM_ACL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-fpm-acl</td>
      <td>N/A</td>
      <td>
        PHP_SAPI_FPM_ACL=ON<br>
        [ACL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-apparmor</td>
      <td>N/A</td>
      <td>PHP_SAPI_FPM_APPARMOR=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-fpm-apparmor</td>
      <td>N/A</td>
      <td>
        PHP_SAPI_FPM_APPARMOR=ON<br>
        [APPARMOR_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-selinux</td>
      <td>N/A</td>
      <td>PHP_SAPI_FPM_SELINUX=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-fpm-selinux</td>
      <td>N/A</td>
      <td>
        PHP_SAPI_FPM_SELINUX=ON<br>
        [SELINUX_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fuzzer</td>
      <td>N/A</td>
      <td>PHP_SAPI_FUZZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--enable-fuzzer<br>
        &emsp;[LIB_FUZZING_ENGINE=...]
      </td>
      <td>N/A</td>
      <td>PHP_SAPI_FUZZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-litespeed</td>
      <td>N/A</td>
      <td>PHP_SAPI_LITESPEED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-litespeed</td>
      <td>N/A</td>
      <td>PHP_SAPI_LITESPEED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-phpdbg</td>
      <td>--enable-phpdbg</td>
      <td>PHP_SAPI_PHPDBG=ON</td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-phpdbg</td>
      <td>--disable-phpdbg</td>
      <td>PHP_SAPI_PHPDBG=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-phpdbg-debug</td>
      <td>--disable-phpdbg-debug</td>
      <td>PHP_SAPI_PHPDBG_DEBUG=OFF</td>
      <td>default (on Windows since PHP >= 8.4)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-phpdbg-debug</td>
      <td>--enable-phpdbg-debug</td>
      <td>PHP_SAPI_PHPDBG_DEBUG=ON</td>
      <td>(on Windows since PHP >= 8.4)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-phpdbg-readline</td>
      <td>N/A</td>
      <td>PHP_SAPI_PHPDBG_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-phpdbg-readline</td>
      <td>N/A</td>
      <td>PHP_SAPI_PHPDBG_READLINE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--disable-phpdbgs</td>
      <td>PHP_SAPI_PHPDBG_SHARED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-phpdbgs</td>
      <td>PHP_SAPI_PHPDBG_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">PHP extensions</th>
    </tr>
    <tr>
      <td>--disable-bcmath</td>
      <td>--disable-bcmath</td>
      <td>PHP_EXT_BCMATH=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-bcmath</td>
      <td>--enable-bcmath</td>
      <td>PHP_EXT_BCMATH=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-bcmath=shared</td>
      <td>--enable-bcmath=shared</td>
      <td>PHP_EXT_BCMATH_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-bz2</td>
      <td>--without-bz2</td>
      <td>PHP_EXT_BZ2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-bz2[=DIR]</td>
      <td>--with-bz2</td>
      <td>
        PHP_EXT_BZ2=ON<br>
        [BZIP2_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-bz2=shared</td>
      <td>--with-bz2=shared</td>
      <td>PHP_EXT_BZ2_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-calendar</td>
      <td>--disable-calendar</td>
      <td>PHP_EXT_CALENDAR=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-calendar</td>
      <td>--enable-calendar</td>
      <td>PHP_EXT_CALENDAR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-calendar=shared</td>
      <td>--enable-calendar=shared</td>
      <td>PHP_EXT_CALENDAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-com-dotnet</td>
      <td>PHP_EXT_COM_DOTNET=ON</td>
      <td>default; Windows only</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-com-dotnet=shared (default PHP &gt;= 8.5)</td>
      <td>PHP_EXT_COM_DOTNET_SHARED=ON</td>
      <td>Windows only</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--disable-com-dotnet</td>
      <td>PHP_EXT_COM_DOTNET=OFF</td>
      <td>Windows only</td>
    </tr>
    <tr>
      <td>--enable-ctype</td>
      <td>--enable-ctype</td>
      <td>PHP_EXT_CTYPE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-ctype=shared</td>
      <td>--enable-ctype=shared</td>
      <td>PHP_EXT_CTYPE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-ctype</td>
      <td>--disable-ctype</td>
      <td>PHP_EXT_CTYPE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-curl</td>
      <td>--without-curl</td>
      <td>PHP_EXT_CURL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-curl<br>
        &emsp;[CURL_CFLAGS=...]<br>
        &emsp;[CURL_LIBS=...]<br>
        &emsp;[CURL_FEATURES=...]
      </td>
      <td>--with-curl</td>
      <td>
        PHP_EXT_CURL=ON<br>
        [CURL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-curl=shared</td>
      <td>--with-curl=shared</td>
      <td>PHP_EXT_CURL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dba</td>
      <td>--without-dba</td>
      <td>PHP_EXT_DBA=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dba</td>
      <td>--with-dba[=DIR]</td>
      <td>PHP_EXT_DBA=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-dba=shared</td>
      <td>--with-dba=shared</td>
      <td>PHP_EXT_DBA_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-flatfile</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_FLATFILE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-flatfile</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_FLATFILE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-inifile</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_INIFILE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-inifile</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_INIFILE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-qdbm</td>
      <td>--without-qdbm</td>
      <td>PHP_EXT_DBA_QDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-qdbm[=DIR]</td>
      <td>--with-qdbm</td>
      <td>
        PHP_EXT_DBA_QDBM=ON<br>
        [QDBM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-gdbm</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_GDBM=OFF (PHP &lt;= 8.3)</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-gdbm[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_GDBM=ON (PHP &lt;= 8.3)<br>
        [GDBM_ROOT=DIR] (PHP &lt;= 8.3)
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ndbm</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_NDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-ndbm[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_NDBM=ON<br>
        [NDBM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db4</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_DB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db4[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_DB=ON<br>
        [BERKELEYDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db3</td>
      <td>--without-db</td>
      <td>PHP_EXT_DBA_DB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db3[=DIR]</td>
      <td>--with-db</td>
      <td>
        PHP_EXT_DBA_DB=ON<br>
        [BERKELEYDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db2</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_DB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db2[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_DB=ON<br>
        [BERKELEYDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db1</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_DB1=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db1[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_DB1=ON<br>
        PHP_EXT_DBA_DB=ON<br>
        [BERKELEYDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-dbm</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_DBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-dbm[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_DBM=ON<br>
        [DBM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-lmdb</td>
      <td>--without-lmdb</td>
      <td>PHP_EXT_DBA_LMDB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-lmdb[=DIR]</td>
      <td>--with-lmdb</td>
      <td>
        PHP_EXT_DBA_LMDB=ON<br>
        [LMDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-tcadb</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_TCADB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-tcadb[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_TCADB=ON<br>
        [TOKYOCABINET_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-cdb</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_CDB=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-cdb=DIR</td>
      <td>N/A</td>
      <td>
        PHP_EXT_DBA_CDB_EXTERNAL=ON<br>
        [CDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-cdb</td>
      <td>N/A</td>
      <td>PHP_EXT_DBA_CDB=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dl-test</td>
      <td>--disable-dl-test</td>
      <td>PHP_EXT_DL_TEST=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dl-test</td>
      <td>--enable-dl-test</td>
      <td>PHP_EXT_DL_TEST=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dl-test=shared</td>
      <td>--enable-dl-test=shared</td>
      <td>PHP_EXT_DL_TEST=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>--enable-dom</td>
      <td>--with-dom</td>
      <td>PHP_EXT_DOM=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dom=shared</td>
      <td>--with-dom=shared</td>
      <td>PHP_EXT_DOM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-dom</td>
      <td>--without-dom</td>
      <td>PHP_EXT_DOM=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-enchant</td>
      <td>--without-enchant</td>
      <td>PHP_EXT_ENCHANT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-enchant<br>
        &emsp;[ENCHANT_CFLAGS=...]<br>
        &emsp;[ENCHANT_LIBS=...]<br>
        &emsp;[ENCHANT2_CFLAGS=...]<br>
        &emsp;[ENCHANT2_LIBS=...]
      </td>
      <td>--with-enchant</td>
      <td>
        PHP_EXT_ENCHANT=ON<br>
        [ENCHANT_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-enchant=shared</td>
      <td>--with-enchant=shared</td>
      <td>PHP_EXT_ENCHANT_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-exif</td>
      <td>--disable-exif</td>
      <td>PHP_EXT_EXIF=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-exif</td>
      <td>--enable-exif</td>
      <td>PHP_EXT_EXIF=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-exif=shared</td>
      <td>--enable-exif=shared</td>
      <td>PHP_EXT_EXIF_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-ffi</td>
      <td>--without-ffi</td>
      <td>PHP_EXT_FFI=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-ffi<br>
        &emsp;[FFI_CFLAGS=...]<br>
        &emsp;[FFI_LIBS=...]
      </td>
      <td>--with-ffi</td>
      <td>
        PHP_EXT_FFI=ON<br>
        [FFI_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-ffi=shared</td>
      <td>--with-ffi=shared</td>
      <td>PHP_EXT_FFI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fileinfo</td>
      <td>--enable-fileinfo</td>
      <td>PHP_EXT_FILEINFO=ON</td>
      <td>default in *nix and Cmake (on Windows by default disabled and can be only shared)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-fileinfo=shared</td>
      <td>--enable-fileinfo=shared</td>
      <td>PHP_EXT_FILEINFO_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-fileinfo</td>
      <td>--disable-fileinfo</td>
      <td>PHP_EXT_FILEINFO=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-filter</td>
      <td>--enable-filter</td>
      <td>PHP_EXT_FILTER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-filter=shared</td>
      <td>--enable-filter=shared</td>
      <td>PHP_EXT_FILTER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-filter</td>
      <td>--disable-filter</td>
      <td>PHP_EXT_FILTER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-ftp</td>
      <td>--disable-ftp</td>
      <td>PHP_EXT_FTP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-ftp</td>
      <td>--enable-ftp</td>
      <td>PHP_EXT_FTP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-ftp=shared</td>
      <td>--enable-ftp=shared</td>
      <td>PHP_EXT_FTP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ftp-ssl</td>
      <td>N/A</td>
      <td>PHP_EXT_FTP_SSL=OFF</td>
      <td>default, PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-ftp-ssl</td>
      <td>N/A</td>
      <td>PHP_EXT_FTP_SSL=ON</td>
      <td>PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--without-openssl-dir</td>
      <td>N/A</td>
      <td>PHP_EXT_FTP_SSL=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl-dir</td>
      <td>N/A</td>
      <td>PHP_EXT_FTP_SSL=ON</td>
      <td>PHP <= 8.3</td>
    </tr>
    <tr>
      <td>--disable-gd</td>
      <td>--without-gd</td>
      <td>PHP_EXT_GD=OFF</td>
      <td>default in Autotools and CMake</td>
    </tr>
    <tr>
      <td>&emsp;--enable-gd</td>
      <td>--with-gd</td>
      <td>PHP_EXT_GD=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-gd=shared</td>
      <td>--with-gd=shared</td>
      <td>PHP_EXT_GD_SHARED=ON</td>
      <td>default in Windows JScript</td>
    </tr>
    <tr>
      <td>&emsp;--without-external-gd</td>
      <td>N/A</td>
      <td>PHP_EXT_GD_EXTERNAL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-external-gd<br>
        &emsp;[GDLIB_CFLAGS=...]<br>
        &emsp;[GDLIB_LIBS=...]
      </td>
      <td>--with-gd=DIR</td>
      <td>
        PHP_EXT_GD_EXTERNAL=ON<br>
        [GD_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-avif</td>
      <td>--without-libavif</td>
      <td>PHP_EXT_GD_AVIF=OFF</td>
      <td>default in Autotools and CMake</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-avif<br>
        &emsp;[AVIF_CFLAGS=...]<br>
        &emsp;[AVIF_LIBS=...]
      </td>
      <td>--with-libavif</td>
      <td>
        PHP_EXT_GD_AVIF=ON<br>
        [LIBAVIF_ROOT=DIR]
      </td>
      <td>default in JScript Windows</td>
    </tr>
    <tr>
      <td>&emsp;--without-webp</td>
      <td>--without-libwebp</td>
      <td>PHP_EXT_GD_WEBP=OFF</td>
      <td>default in Autotools and CMake</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-webp<br>
        &emsp;[WEBP_CFLAGS=...]<br>
        &emsp;[WEBP_LIBS=...]
      </td>
      <td>--with-libwebp</td>
      <td>
        PHP_EXT_GD_WEBP=ON<br>
        [WEBP_ROOT=DIR]
      </td>
      <td>default in JScript Windows</td>
    </tr>
    <tr>
      <td>&emsp;--without-jpeg</td>
      <td>N/A</td>
      <td>PHP_EXT_GD_JPEG=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-jpeg<br>
        &emsp;[JPEG_CFLAGS=...]<br>
        &emsp;[JPEG_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_GD_JPEG=ON<br>
        [JPEG_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>
        &emsp;[PNG_CFLAGS=...]<br>
        &emsp;[PNG_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        [PNG_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-xpm</td>
      <td>N/A</td>
      <td>PHP_EXT_GD_XPM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-xpm<br>
        &emsp;[XPM_CFLAGS=...]<br>
        &emsp;[XPM_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_GD_XPM=ON<br>
        [XPM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-freetype</td>
      <td>N/A</td>
      <td>PHP_EXT_GD_FREETYPE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-freetype<br>
        &emsp;[FREETYPE2_CFLAGS=...]<br>
        &emsp;[FREETYPE2_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_GD_FREETYPE=ON<br>
        [FREETYPE_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-gd-jis-conv</td>
      <td>N/A</td>
      <td>PHP_EXT_GD_JIS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-gd-jis-conv</td>
      <td>N/A</td>
      <td>PHP_EXT_GD_JIS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-gettext</td>
      <td>--without-gettext</td>
      <td>PHP_EXT_GETTEXT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-gettext[=DIR]</td>
      <td>--with-gettext</td>
      <td>
        PHP_EXT_GETTEXT=ON<br>
        [INTL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-gettext=shared</td>
      <td>--with-gettext=shared</td>
      <td>PHP_EXT_GETTEXT_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-gmp</td>
      <td>--without-gmp</td>
      <td>PHP_EXT_GMP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-gmp[=DIR]</td>
      <td>--with-gmp</td>
      <td>
        PHP_EXT_GMP=ON<br>
        [GMP_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-gmp=shared</td>
      <td>--with-gmp=shared</td>
      <td>PHP_EXT_GMP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mhash</td>
      <td>--without-mhash</td>
      <td>PHP_EXT_HASH_MHASH=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-mhash</td>
      <td>--with-mhash</td>
      <td>PHP_EXT_HASH_MHASH=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-iconv[=DIR]</td>
      <td>--with-iconv</td>
      <td>
        PHP_EXT_ICONV=ON<br>
        [ICONV_ROOT=DIR]
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-iconv=shared</td>
      <td>--with-iconv=shared</td>
      <td>PHP_EXT_ICONV_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-iconv</td>
      <td>--without-iconv</td>
      <td>PHP_EXT_ICONV=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-imap</td>
      <td>--without-imap</td>
      <td>PHP_EXT_IMAP=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-imap[=DIR]</td>
      <td>--with-imap</td>
      <td>
        PHP_EXT_IMAP=ON<br>
        [CCLIENT_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-kerberos</td>
      <td>N/A</td>
      <td>PHP_EXT_IMAP_KERBEROS=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-kerberos<br>
        &emsp;[KERBEROS_CFLAGS=...]<br>
        &emsp;[KERBEROS_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_IMAP_KERBEROS=ON<br>
        [KERBEROS_ROOT=...]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-imap-ssl</td>
      <td>N/A</td>
      <td>PHP_EXT_IMAP_SSL=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-imap-ssl<br>
        &emsp;[OPENSSL_CFLAGS=...]<br>
        &emsp;[OPENSSL_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_IMAP_SSL=ON<br>
        [OPENSSL_ROOT_DIR=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-intl</td>
      <td>--disable-intl</td>
      <td>PHP_EXT_INTL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--enable-intl<br>
        &emsp;[ICU_CFLAGS=...]<br>
        &emsp;[ICU_LIBS=...]
      </td>
      <td>--enable-intl</td>
      <td>
        PHP_EXT_INTL=ON<br>
        [ICU_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-intl=shared</td>
      <td>--enable-intl=shared</td>
      <td>PHP_EXT_INTL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-ldap</td>
      <td>--without-ldap</td>
      <td>PHP_EXT_LDAP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-ldap[=DIR]
      </td>
      <td>--with-ldap</td>
      <td>
        PHP_EXT_LDAP=ON<br>
        [LDAP_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-ldap=shared</td>
      <td>--with-ldap=shared</td>
      <td>PHP_EXT_LDAP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ldap-sasl</td>
      <td>N/A</td>
      <td>PHP_EXT_LDAP_SASL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-ldap-sasl<br>
        &emsp;[SASL_CFLAGS=...]<br>
        &emsp;[SASL_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_LDAP_SASL=ON<br>
        [SASL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>
        --with-libxml<br>
        [LIBXML_CFLAGS=...]<br>
        [LIBXML_LIBS=...]
      </td>
      <td>--with-libxml</td>
      <td>
        PHP_EXT_LIBXML=ON<br>
        [LIBXML2_ROOT=DIR]
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--without-libxml</td>
      <td>--without-libxml</td>
      <td>PHP_EXT_LIBXML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-mbstring</td>
      <td>--disable-mbstring</td>
      <td>PHP_EXT_MBSTRING=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-mbstring</td>
      <td>--enable-mbstring</td>
      <td>PHP_EXT_MBSTRING=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-mbstring=shared</td>
      <td>--enable-mbstring=shared</td>
      <td>PHP_EXT_MBSTRING_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>
        &emsp;--enable-mbregex<br>
        &emsp;[ONIG_CFLAGS=...]<br>
        &emsp;[ONIG_LIBS=...]
      </td>
      <td>--enable-mbregex</td>
      <td>
        PHP_EXT_MBSTRING_MBREGEX=ON<br>
        [ONIGURUMA_ROOT=DIR]
      </td>
      <td>default in *nix and CMake (on Windows disabled)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-mbregex</td>
      <td>--disable-mbregex</td>
      <td>PHP_EXT_MBSTRING_MBREGEX=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysqli</td>
      <td>--without-mysqli</td>
      <td>PHP_EXT_MYSQLI=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-mysqli</td>
      <td>--with-mysqli</td>
      <td>PHP_EXT_MYSQLI=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-mysqli=shared</td>
      <td>--with-mysqli=shared</td>
      <td>PHP_EXT_MYSQLI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysql-sock</td>
      <td>N/A</td>
      <td>PHP_EXT_MYSQL_SOCKET=OFF</td>
      <td>default, not available on Windows</td>
    </tr>
    <tr>
      <td>&emsp;--with-mysql-sock</td>
      <td>N/A</td>
      <td>PHP_EXT_MYSQL_SOCKET=ON</td>
      <td>Not available on Windows</td>
    </tr>
    <tr>
      <td>&emsp;--with-mysql-sock=SOCKET</td>
      <td>N/A</td>
      <td>
        PHP_EXT_MYSQL_SOCKET=ON<br>
        PHP_EXT_MYSQL_SOCKET_PATH=/path/to/mysql.sock
      </td>
      <td>Not available on Windows</td>
    </tr>
    <tr>
      <td>--disable-mysqlnd</td>
      <td>--without-mysqlnd</td>
      <td>PHP_EXT_MYSQLND=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-mysqlnd</td>
      <td>--with-mysqlnd</td>
      <td>PHP_EXT_MYSQLND=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-mysqlnd=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_MYSQLND_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-mysqlnd-compression-support</td>
      <td>N/A (enabled by default)</td>
      <td>PHP_EXT_MYSQLND_COMPRESSION=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-mysqlnd-compression-support</td>
      <td>N/A</td>
      <td>PHP_EXT_MYSQLND_COMPRESSION=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysqlnd-ssl</td>
      <td>N/A</td>
      <td>PHP_EXT_MYSQLND_SSL=OFF</td>
      <td>PHP >= 8.4 (default in Autotools)</td>
    </tr>
    <tr>
      <td>--with-mysqlnd-ssl</td>
      <td>N/A</td>
      <td>PHP_EXT_MYSQLND_SSL=ON</td>
      <td>PHP >= 8.4 (default in CMake)</td>
    </tr>
    <tr>
      <td>--without-oci8</td>
      <td>N/A</td>
      <td>PHP_EXT_OCI8=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-oci8[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_OCI8=ON<br>
        [...]
      </td>
      <td>PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-oci8=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_OCI8_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--without-oci8-11g</td>
      <td>PHP_EXT_OCI8_11G=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--with-oci8-11g</td>
      <td>PHP_EXT_OCI8_11G=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--without-oci8-12c</td>
      <td>PHP_EXT_OCI8_12C=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--with-oci8-12c</td>
      <td>PHP_EXT_OCI8_12C=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--without-oci8-19</td>
      <td>PHP_EXT_OCI8_19=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--with-oci8-19</td>
      <td>PHP_EXT_OCI8_19=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-odbc</td>
      <td>PHP_EXT_ODBC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-odbc</td>
      <td>PHP_EXT_ODBC=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-odbc=shared</td>
      <td>PHP_EXT_ODBC_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-odbcver</td>
      <td>--without-odbcver</td>
      <td>PHP_EXT_ODBC_VERSION="0x0350"</td>
      <td>default: 0x0350</td>
    </tr>
    <tr>
      <td>&emsp;--with-odbcver[=HEX]</td>
      <td>--with-odbcver[=HEX]</td>
      <td>PHP_EXT_ODBC_VERSION=HEX</td>
      <td>default: 0x0350</td>
    </tr>
    <tr>
      <td>&emsp;--without-adabas</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-adabas</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=adabas<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-sapdb</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-sapdb</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=sapdb<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-solid</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-solid</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=solid<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ibm-db2</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-ibm-db2</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=ibm-db2<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-empress</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-empress</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=empress<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-empress-bcs</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-empress-bcs</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=empress-bcs<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-custom-odbc</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-custom-odbc</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=custom<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-iodbc</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-iodbc<br>
        &emsp;[ODBC_CFLAGS=...]<br>
        &emsp;[ODBC_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=iODBC<br>
        [ODBC_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-esoob</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-esoob</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=esoob<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-unixODBC</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-unixODBC<br>
        &emsp;[ODBC_CFLAGS=...]<br>
        &emsp;[ODBC_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=unixODBC<br>
        [ODBC_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-dbmaker</td>
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-dbmaker[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_ODBC=ON<br>
        PHP_EXT_ODBC_TYPE=dbmaker<br>
        ODBC_LIBRARY=...
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-opcache</td>
      <td>--enable-opcache</td>
      <td>PHP_EXT_OPCACHE=ON</td>
      <td>default, will be shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-opcache=shared</td>
      <td>--enable-opcache=shared</td>
      <td>PHP_EXT_OPCACHE=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>&emsp;--disable-opcache</td>
      <td>--disable-opcache</td>
      <td>PHP_EXT_OPCACHE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-huge-code-pages</td>
      <td>N/A</td>
      <td>PHP_EXT_OPCACHE_HUGE_CODE_PAGES=ON</td>
      <td>default; For non-Windows platforms</td>
    </tr>
    <tr>
      <td>&emsp;--disable-huge-code-pages</td>
      <td>N/A</td>
      <td>PHP_EXT_OPCACHE_HUGE_CODE_PAGES=OFF</td>
      <td>For non-Windows platforms</td>
    </tr>
    <tr>
      <td>&emsp;--enable-opcache-jit</td>
      <td>--enable-opcache-jit</td>
      <td>PHP_EXT_OPCACHE_JIT=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-opcache-jit</td>
      <td>--disable-opcache-jit</td>
      <td>PHP_EXT_OPCACHE_JIT=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-capstone</td>
      <td>N/A</td>
      <td>PHP_EXT_OPCACHE_CAPSTONE=OFF</td>
      <td>default; For non-Windows platforms</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-capstone<br>
        &emsp;[CAPSTONE_CFLAGS=...]<br>
        &emsp;[CAPSTONE_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_OPCACHE_CAPSTONE=ON<br>
        [CAPSTONE_ROOT=DIR]
      </td>
      <td>For non-Windows platforms</td>
    </tr>
    <tr>
      <td>--without-openssl</td>
      <td>--without-openssl</td>
      <td>PHP_EXT_OPENSSL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-openssl<br>
        &emsp;[OPENSSL_CFLAGS=...]<br>
        &emsp;[OPENSSL_LIBS=...]
      </td>
      <td>--with-openssl</td>
      <td>
        PHP_EXT_OPENSSL=ON<br>
        [OPENSSL_ROOT_DIR=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl=shared</td>
      <td>--with-openssl=shared</td>
      <td>PHP_EXT_OPENSSL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-openssl-argon2</td>
      <td>--without-openssl-argon2</td>
      <td>PHP_EXT_OPENSSL_ARGON2=OFF</td>
      <td>default, PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl-argon2</td>
      <td>--with-openssl-argon2</td>
      <td>PHP_EXT_OPENSSL_ARGON2=ON</td>
      <td>PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--without-openssl-legacy-provider</td>
      <td>--without-openssl-legacy-provider</td>
      <td>PHP_EXT_OPENSSL_LEGACY_PROVIDER=OFF</td>
      <td>default, PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl-legacy-provider</td>
      <td>--with-openssl-legacy-provider</td>
      <td>PHP_EXT_OPENSSL_LEGACY_PROVIDER=ON</td>
      <td>PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--without-kerberos</td>
      <td>N/A</td>
      <td>PHP_EXT_OPENSSL_KERBEROS=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-kerberos<br>
        [KERBEROS_CFLAGS=...]<br>
        [KERBEROS_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_OPENSSL_KERBEROS=ON<br>
        [KERBEROS_ROOT=DIR]
      </td>
      <td>PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--without-system-ciphers</td>
      <td>N/A</td>
      <td>PHP_EXT_OPENSSL_SYSTEM_CIPHERS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-system-ciphers</td>
      <td>N/A</td>
      <td>PHP_EXT_OPENSSL_SYSTEM_CIPHERS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-pcntl</td>
      <td>N/A</td>
      <td>PHP_EXT_PCNTL=OFF</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-pcntl</td>
      <td>N/A</td>
      <td>PHP_EXT_PCNTL=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-pcntl=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_PCNTL_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--with-pcre-jit</td>
      <td>--with-pcre-jit</td>
      <td>PHP_EXT_PCRE_JIT=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--without-pcre-jit</td>
      <td>--without-pcre-jit</td>
      <td>PHP_EXT_PCRE_JIT=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-external-pcre</td>
      <td>N/A</td>
      <td>PHP_EXT_PCRE_EXTERNAL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-external-pcre<br>
        &emsp;[PCRE2_CFLAGS=...]<br>
        &emsp;[PCRE2_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_PCRE_EXTERNAL=ON<br>
        [PCRE_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-pdo</td>
      <td>--enable-pdo</td>
      <td>PHP_EXT_PDO=ON</td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-pdo=shared</td>
      <td>&emsp;--enable-pdo=shared</td>
      <td>PHP_EXT_PDO_SHARED=ON</td>
      <td>(on Windows can't be built as shared yet)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-pdo</td>
      <td>&emsp;--disable-pdo</td>
      <td>PHP_EXT_PDO=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-dblib</td>
      <td>--without-pdo-dblib</td>
      <td>PHP_EXT_PDO_DBLIB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-pdo-dblib[=DIR]
      </td>
      <td>--with-pdo-dblib</td>
      <td>
        PHP_EXT_PDO_DBLIB=ON<br>
        [FREETDS_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-dblib=shared</td>
      <td>--with-pdo-dblib=shared</td>
      <td>PHP_EXT_PDO_DBLIB_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--without-pdo-mssql</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--with-pdo-mssql</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--with-pdo-mssql=shared</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-firebird</td>
      <td>--without-pdo-firebird</td>
      <td>PHP_EXT_PDO_FIREBIRD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-firebird[=DIR]</td>
      <td>--with-pdo-firebird</td>
      <td>
        PHP_EXT_PDO_FIREBIRD=ON<br>
        [FIREBIRD_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-firebird=shared</td>
      <td>--with-pdo-firebird=shared</td>
      <td>PHP_EXT_PDO_FIREBIRD_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-mysql</td>
      <td>--without-pdo-mysql</td>
      <td>PHP_EXT_PDO_MYSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql</td>
      <td>--with-pdo-mysql</td>
      <td>PHP_EXT_PDO_MYSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=mysqlnd</td>
      <td>--with-pdo-mysql=mysqlnd</td>
      <td>PHP_EXT_PDO_MYSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=shared</td>
      <td>--with-pdo-mysql=shared</td>
      <td>PHP_EXT_PDO_MYSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=/usr</td>
      <td>--with-pdo-mysql=[DIR]</td>
      <td>
        PHP_EXT_PDO_MYSQL=ON<br>
        PHP_EXT_PDO_MYSQL_DRIVER=mysql
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=DIR</td>
      <td>--with-pdo-mysql=[DIR]</td>
      <td>
        PHP_EXT_PDO_MYSQL=ON<br>
        PHP_EXT_PDO_MYSQL_DRIVER=mysql<br>
        MYSQL_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=path/to/mysql_config</td>
      <td>N/A</td>
      <td>
        PHP_EXT_PDO_MYSQL=ON<br>
        PHP_EXT_PDO_MYSQL_DRIVER=mysql<br>
        MySQL_CONFIG_EXECUTABLE=path/to/mysql_config
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-oci</td>
      <td>--without-pdo-oci</td>
      <td>PHP_EXT_PDO_OCI=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-oci[=DIR]</td>
      <td>--with-pdo-oci[=DIR]</td>
      <td>
        PHP_EXT_PDO_OCI=ON<br>
        [...]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-oci=shared</td>
      <td>--with-pdo-oci=shared</td>
      <td>PHP_EXT_PDO_OCI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-odbc</td>
      <td>--without-pdo-odbc</td>
      <td>PHP_EXT_PDO_ODBC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-odbc=type</td>
      <td>--with-pdo-odbc</td>
      <td>
        PHP_EXT_PDO_ODBC=ON<br>
        [PHP_EXT_PDO_ODBC_TYPE=type]
      </td>
      <td>Default type: unixODBC (Autotools), auto (CMake)</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-odbc=type,dir,libname,ldflags,cflags</td>
      <td>--with-pdo-odbc</td>
      <td>
        PHP_EXT_PDO_ODBC=ON<br>
        PHP_EXT_PDO_ODBC_TYPE=type<br>
        [ODBC_ROOT=dir]<br>
        ODBC_LIBRARY=libname<br>
        [ODBC_INCLUDE_DIR=includedir]<br>
        [ODBC_LINK_OPTIONS=ldflags]<br>
        [ODBC_COMPILE_OPTIONS=cflags]<br>
        [ODBC_COMPILE_DEFINITIONS=...]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-odbc=shared</td>
      <td>--with-pdo-odbc=shared</td>
      <td>PHP_EXT_PDO_ODBC_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-pgsql</td>
      <td>--without-pdo-pgsql</td>
      <td>PHP_EXT_PDO_PGSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-pdo-pgsql[=DIR]<br>
        &emsp;[PGSQL_CFLAGS=...]<br>
        &emsp;[PGSQL_LIBS=...]
      </td>
      <td>--with-pdo-pgsql</td>
      <td>
        PHP_EXT_PDO_PGSQL=ON<br>
        [POSTGRESQL_ROOT=DIR]
      </td>
      <td>Autotools PGSQL_CFLAGS and PGSQL_LIBS available since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-pgsql=shared</td>
      <td>--with-pdo-pgsql=shared</td>
      <td>PHP_EXT_PDO_PGSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>
        &emsp;--with-pdo-sqlite<br>
        &emsp;[SQLITE_CFLAGS=...]<br>
        &emsp;[SQLITE_LIBS=...]
      </td>
      <td>--with-pdo-sqlite</td>
      <td>
        PHP_EXT_PDO_SQLITE=ON<br>
        [SQLITE3_ROOT=DIR]
      </td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-sqlite=shared</td>
      <td>--with-pdo-sqlite=shared</td>
      <td>PHP_EXT_PDO_SQLITE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-sqlite</td>
      <td>--without-pdo-sqlite</td>
      <td>PHP_EXT_PDO_SQLITE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-pgsql</td>
      <td>--without-pgsql</td>
      <td>PHP_EXT_PGSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-pgsql[=DIR]<br>
        &emsp;[PGSQL_CFLAGS=...]<br>
        &emsp;[PGSQL_LIBS=...]
      </td>
      <td>--with-pgsql</td>
      <td>
        PHP_EXT_PGSQL=ON<br>
        [POSTGRESQL_ROOT=DIR]
      </td>
      <td>Autotools PGSQL_CFLAGS and PGSQL_LIBS available since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-pgsql=shared</td>
      <td>--with-pgsql=shared</td>
      <td>PHP_EXT_PGSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-phar</td>
      <td>--enable-phar</td>
      <td>PHP_EXT_PHAR=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-phar=shared</td>
      <td>--enable-phar=shared</td>
      <td>PHP_EXT_PHAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-phar</td>
      <td>--disable-phar</td>
      <td>PHP_EXT_PHAR=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--disable-phar-native-ssl</td>
      <td>N/A</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-phar-native-ssl</td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;N/A</td>
      <td>--enable-phar-native-ssl=shared</td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-posix</td>
      <td>N/A</td>
      <td>PHP_EXT_POSIX=ON</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-posix=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_POSIX_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--disable-posix</td>
      <td>N/A</td>
      <td>PHP_EXT_POSIX=OFF</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--without-pspell</td>
      <td>--without-pspell</td>
      <td>PHP_EXT_PSPELL=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-pspell[=DIR]</td>
      <td>--with-pspell</td>
      <td>
        PHP_EXT_PSPELL=ON<br>
        [ASPELL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pspell=shared</td>
      <td>--with-pspell=shared</td>
      <td>PHP_EXT_PSPELL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-libedit</td>
      <td>--without-readline</td>
      <td>PHP_EXT_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-libedit<br>
        &emsp;[EDIT_CFLAGS=...]<br>
        &emsp;[EDIT_LIBS=...]
      </td>
      <td>--with-readline</td>
      <td>
        PHP_EXT_READLINE=ON<br>
        [EDITLINE_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-libedit=shared</td>
      <td>--with-readline=shared</td>
      <td>PHP_EXT_READLINE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-readline</td>
      <td>--without-readline</td>
      <td>PHP_EXT_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-readline[=DIR]</td>
      <td>N/A</td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-readline=shared</td>
      <td>N/A</td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-session</td>
      <td>--enable-session</td>
      <td>PHP_EXT_SESSION=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-session=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_SESSION_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-session</td>
      <td>--disable-session</td>
      <td>PHP_EXT_SESSION=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-mm</td>
      <td>N/A</td>
      <td>PHP_EXT_SESSION_MM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-mm[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_EXT_SESSION_MM=ON<br>
        [MM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-shmop</td>
      <td>--disable-shmop</td>
      <td>PHP_EXT_SHMOP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-shmop</td>
      <td>--enable-shmop</td>
      <td>PHP_EXT_SHMOP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-shmop=shared</td>
      <td>--enable-shmop=shared</td>
      <td>PHP_EXT_SHMOP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-simplexml</td>
      <td>--with-simplexml</td>
      <td>PHP_EXT_SIMPLEXML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-simplexml=shared</td>
      <td>--with-simplexml=shared</td>
      <td>PHP_EXT_SIMPLEXML_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-simplexml</td>
      <td>--without-simplexml</td>
      <td>PHP_EXT_SIMPLEXML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-snmp</td>
      <td>--without-snmp</td>
      <td>PHP_EXT_SNMP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-snmp[=DIR]</td>
      <td>--with-snmp[=DIR]</td>
      <td>
        PHP_EXT_SNMP=ON<br>
        [NETSNMP_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-snmp=shared</td>
      <td>--with-snmp=shared</td>
      <td>PHP_EXT_SNMP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-soap</td>
      <td>--disable-soap</td>
      <td>PHP_EXT_SOAP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-soap</td>
      <td>--enable-soap</td>
      <td>PHP_EXT_SOAP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-soap=shared</td>
      <td>--enable-soap=shared</td>
      <td>PHP_EXT_SOAP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sockets</td>
      <td>--disable-sockets</td>
      <td>PHP_EXT_SOCKETS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sockets</td>
      <td>--enable-sockets</td>
      <td>PHP_EXT_SOCKETS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-sockets=shared</td>
      <td>--enable-sockets=shared</td>
      <td>PHP_EXT_SOCKETS_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-sodium</td>
      <td>--without-sodium</td>
      <td>PHP_EXT_SODIUM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-sodium<br>
        &emsp;[LIBSODIUM_CFLAGS=...]<br>
        &emsp;[LIBSODIUM_LIBS=..]
      </td>
      <td>--with-sodium</td>
      <td>
        PHP_EXT_SODIUM=ON<br>
        [SODIUM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-sodium=shared</td>
      <td>--with-sodium=shared</td>
      <td>PHP_EXT_SODIUM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>
        --with-sqlite3<br>
        [SQLITE_CFLAGS=...]<br>
        [SQLITE_LIBS=...]
      </td>
      <td>--with-sqlite3</td>
      <td>
        PHP_EXT_SQLITE3=ON<br>
        [SQLITE3_ROOT=DIR]
      </td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--with-sqlite3=shared</td>
      <td>--with-sqlite3=shared</td>
      <td>PHP_EXT_SQLITE3_SHARED</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-sqlite3</td>
      <td>--without-sqlite3</td>
      <td>PHP_EXT_SQLITE3=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-external-libcrypt</td>
      <td>N/A</td>
      <td>PHP_EXT_STANDARD_CRYPT_EXTERNAL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-external-libcrypt</td>
      <td>N/A</td>
      <td>PHP_EXT_STANDARD_CRYPT_EXTERNAL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-password-argon2</td>
      <td>--without-password-argon2</td>
      <td>PHP_EXT_STANDARD_ARGON2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-password-argon2<br>
        &emsp;[ARGON2_CFLAGS=...]<br>
        &emsp;[ARGON2_LIBS=...]
      </td>
      <td>--with-password-argon2</td>
      <td>
        PHP_EXT_STANDARD_ARGON2=ON<br>
        [ARGON2_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sysvmsg</td>
      <td>N/A</td>
      <td>PHP_EXT_SYSVMSG=OFF</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvmsg</td>
      <td>N/A</td>
      <td>PHP_EXT_SYSVMSG=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvmsg=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_SYSVMSG_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--disable-sysvsem</td>
      <td>N/A</td>
      <td>PHP_EXT_SYSVSEM=OFF</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvsem</td>
      <td>N/A</td>
      <td>PHP_EXT_SYSVSEM=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvsem=shared</td>
      <td>N/A</td>
      <td>PHP_EXT_SYSVSEM_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--disable-sysvshm</td>
      <td>--disable-sysvshm</td>
      <td>PHP_EXT_SYSVSHM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvshm</td>
      <td>--enable-sysvshm</td>
      <td>PHP_EXT_SYSVSHM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvshm=shared</td>
      <td>--enable-sysvshm=shared</td>
      <td>PHP_EXT_SYSVSHM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-tidy</td>
      <td>--without-tidy</td>
      <td>PHP_EXT_TIDY=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-tidy[=DIR]</td>
      <td>--with-tidy</td>
      <td>
        PHP_EXT_TIDY=ON<br>
        [TIDY_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-tidy=shared</td>
      <td>--with-tidy=shared</td>
      <td>PHP_EXT_TIDY_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-tokenizer</td>
      <td>--enable-tokenizer</td>
      <td>PHP_EXT_TOKENIZER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-tokenizer=shared</td>
      <td>--enable-tokenizer=shared</td>
      <td>PHP_EXT_TOKENIZER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-tokenizer</td>
      <td>--disable-tokenizer</td>
      <td>PHP_EXT_TOKENIZER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xml</td>
      <td>--with-xml</td>
      <td>PHP_EXT_XML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-xml=shared</td>
      <td>--with-xml=shared</td>
      <td>PHP_EXT_XML_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-xml</td>
      <td>--without-xml</td>
      <td>PHP_EXT_XML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-expat</td>
      <td>N/A</td>
      <td>PHP_EXT_XML_EXPAT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-expat<br>
        &emsp;[EXPAT_CFLAGS=...]<br>
        &emsp;[EXPAT_LIBS=...]
      </td>
      <td>N/A</td>
      <td>
        PHP_EXT_XML_EXPAT=ON<br>
        [EXPAT_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xmlreader</td>
      <td>--enable-xmlreader</td>
      <td>PHP_EXT_XMLREADER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-xmlreader=shared</td>
      <td>--enable-xmlreader=shared</td>
      <td>PHP_EXT_XMLREADER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-xmlreader</td>
      <td>--disable-xmlreader</td>
      <td>PHP_EXT_XMLREADER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xmlwriter</td>
      <td>--enable-xmlwriter</td>
      <td>PHP_EXT_XMLWRITER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-xmlwriter=shared</td>
      <td>--enable-xmlwriter=shared</td>
      <td>PHP_EXT_XMLWRITER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-xmlwriter</td>
      <td>--disable-xmlwriter</td>
      <td>PHP_EXT_XMLWRITER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-xsl</td>
      <td>--without-xsl</td>
      <td>PHP_EXT_XSL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-xsl<br>
        &emsp;[XSL_CFLAGS=...]<br>
        &emsp;[XSL_LIBS=...]<br>
        &emsp;[EXSLT_CFLAGS=...]<br>
        &emsp;[EXSLT_LIBS=...]
      </td>
      <td>--with-xsl</td>
      <td>
        PHP_EXT_XSL=ON<br>
        [LIBXSLT_ROOT=DIR]<br>
        [CMAKE_PREFIX_PATH=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-xsl=shared</td>
      <td>--with-xsl=shared</td>
      <td>PHP_EXT_XSL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zend-test</td>
      <td>--disable-zend-test</td>
      <td>PHP_EXT_ZEND_TEST=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-zend-test</td>
      <td>--enable-zend-test</td>
      <td>PHP_EXT_ZEND_TEST=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-zend-test=shared</td>
      <td>--enable-zend-test=shared</td>
      <td>PHP_EXT_ZEND_TEST_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-zip</td>
      <td>--disable-zip</td>
      <td>PHP_EXT_ZIP=OFF</td>
      <td>default in *nix and CMake (on Windows enabled and shared by default)</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-zip<br>
        &emsp;[LIBZIP_CFLAGS=...]<br>
        &emsp;[LIBZIP_LIBS=...]
      </td>
      <td>--enable-zip</td>
      <td>
        PHP_EXT_ZIP=ON<br>
        LIBZIP_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-zip=shared</td>
      <td>--enable-zip=shared</td>
      <td>PHP_EXT_ZIP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-zlib</td>
      <td>--disable-zlib</td>
      <td>PHP_EXT_ZLIB=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-zlib<br>
        &emsp;[ZLIB_CFLAGS=...]<br>
        &emsp;[ZLIB_LIBS=...]
      </td>
      <td>--enable-zlib</td>
      <td>
        PHP_EXT_ZLIB=ON<br>
        [ZLIB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-zlib=shared</td>
      <td>--enable-zlib=shared</td>
      <td>PHP_EXT_ZLIB_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">PEAR configuration</th>
    </tr>
    <tr>
      <td>--without-pear</td>
      <td>N/A</td>
      <td>PHP_PEAR=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pear[=DIR]</td>
      <td>N/A</td>
      <td>
        PHP_PEAR=ON<br>
        [PHP_PEAR_DIR=DIR]<br>
        [PHP_PEAR_TEMP_DIR=DIR]<br>
      </td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">Autoconf options</th>
    </tr>
    <tr>
      <td>--program-prefix=prefix</td>
      <td>N/A</td>
      <td>PHP_PROGRAM_PREFIX="prefix"</td>
      <td></td>
    </tr>
    <tr>
      <td>--program-suffix=suffix</td>
      <td>N/A</td>
      <td>PHP_PROGRAM_SUFFIX="suffix"</td>
      <td></td>
    </tr>
    <tr>
      <td>--program-transform-name=expression</td>
      <td>N/A</td>
      <td>N/A</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">Libtool options</th>
    </tr>
    <tr>
      <td>--enable-shared=PKGS</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-static=PKGS</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fast-install=PKGS</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--with-gnu-ld</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-libtool-lock</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--with-pic</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>--with-tags=TAGS</td>
      <td>N/A</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">Windows JScript options</th>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-verbosity</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--without-verbosity</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-toolset</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--without-toolset</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-cygwin</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-object-out-dir</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-pgi</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-pgo</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-mp</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-php-build</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-extra-includes</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-extra-libs</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-analyzer</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-snapshot-template</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-security-flags</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--without-uncritical-warn-choke</td>
      <td></td>
      <td>Removed since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-uncritical-warn-choke</td>
      <td></td>
      <td>Automatically enabled when using Clang. Removed since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-sanitizer</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-codegen-arch</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-all-shared</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-config-profile</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-test-ini</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-test-ini-ext-exclude</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-native-intrinsics</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-vs-link-compat</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">Other options</th>
    </tr>
    <tr>
      <td>--prefix=PREFIX</td>
      <td>--with-prefix=PREFIX</td>
      <td>CMAKE_INSTALL_PREFIX</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">Influential variables</th>
    </tr>
    <tr>
      <td>CC=&quot;...&quot;</td>
      <td></td>
      <td>CMAKE_C_COMPILER=&quot;...&quot;</td>
      <td>C compiler command</td>
    </tr>
    <tr>
      <td>CXX=&quot;...&quot;</td>
      <td></td>
      <td>CMAKE_CXX_COMPILER=&quot;...&quot;</td>
      <td>C++ compiler command</td>
    </tr>
    <tr>
      <td>CFLAGS=&quot;...&quot;</td>
      <td>CFLAGS=&quot;...&quot;</td>
      <td>CFLAGS (environment variable) or CMAKE_C_FLAGS</td>
      <td>C compiler flags</td>
    </tr>
    <tr>
      <td>CXXFLAGS=&quot;...&quot;</td>
      <td></td>
      <td>CXXFLAGS (environment variable) or CMAKE_CXX_FLAGS</td>
      <td>C++ compiler flags</td>
    </tr>
    <tr>
      <td>CPPFLAGS=&quot;...&quot;</td>
      <td></td>
      <td>N/A</td>
      <td>preprocessor flags</td>
    </tr>
    <tr>
      <td>CPP=&quot;...&quot;</td>
      <td></td>
      <td></td>
      <td>C preprocessor</td>
    </tr>
    <tr>
      <td>CXXCPP=&quot;...&quot;</td>
      <td></td>
      <td></td>
      <td>C++ preprocessor</td>
    </tr>
    <tr>
      <td>LDFLAGS=&quot;...&quot;</td>
      <td>LDFLAGS=&quot;...&quot;</td>
      <td>
        CMAKE_EXE_LINKER_FLAGS=&quot;...&quot;<br>
        CMAKE_SHARED_LINKER_FLAGS=&quot;...&quot;
      </td>
      <td>linker flags</td>
    </tr>
    <tr>
      <td>LIBS=&quot;...&quot;</td>
      <td></td>
      <td>CMAKE_&lt;LANG&gt;_STANDARD_LIBRARIES</td>
      <td>libraries to pass to the linker</td>
    </tr>
    <tr>
      <td>PHP_EXTRA_VERSION=&quot;-acme&quot;</td>
      <td></td>
      <td>PHP_VERSION_LABEL=&quot;-acme&quot;</td>
      <td>-dev or empty</td>
    </tr>
    <tr>
      <td>PHP_UNAME=&quot;ACME Linux&quot;</td>
      <td></td>
      <td>PHP_UNAME=&quot;ACME Linux&quot;</td>
      <td><code>uname -a</code> output override</td>
    </tr>
    <tr>
      <td>PHP_BUILD_SYSTEM=&quot;ACME Linux&quot;</td>
      <td>PHP_BUILD_SYSTEM=&quot;Microsoft Windows...&quot;</td>
      <td>PHP_BUILD_SYSTEM=&quot;...&quot;</td>
      <td>Builder system name, defaults to <code>uname -a</code> output</td>
    </tr>
    <tr>
      <td>PHP_BUILD_PROVIDER=&quot;ACME&quot;</td>
      <td>PHP_BUILD_PROVIDER=&quot;ACME&quot;</td>
      <td>PHP_BUILD_PROVIDER=&quot;ACME&quot;</td>
      <td>Build provider</td>
    </tr>
    <tr>
      <td>PHP_BUILD_COMPILER=&quot;...&quot;</td>
      <td>PHP_BUILD_COMPILER=&quot;...&quot;</td>
      <td>PHP_BUILD_COMPILER=&quot;...&quot;</td>
      <td>Compiler used for build</td>
    </tr>
    <tr>
      <td>PHP_BUILD_ARCH=&quot;...&quot;</td>
      <td>PHP_BUILD_ARCH=&quot;...&quot;</td>
      <td>PHP_BUILD_ARCH=&quot;...&quot;</td>
      <td>Build architecture</td>
    </tr>
    <tr>
      <td>EXTENSION_DIR=&quot;path/to/ext&quot;</td>
      <td></td>
      <td>PHP_EXTENSION_DIR=&quot;path/to/ext&quot;</td>
      <td>Override the INI extension_dir</td>
    </tr>
    <tr>
      <td>PKG_CONFIG=&quot;path/to/pkgconf&quot;</td>
      <td></td>
      <td>PKG_CONFIG_EXECUTABLE=&quot;path/to/pkgconf&quot;</td>
      <td>path to pkg-config utility</td>
    </tr>
    <tr>
      <td>PKG_CONFIG_PATH=&quot;...&quot;</td>
      <td></td>
      <td>ENV{PKG_CONFIG_PATH}=&quot;...&quot; (environment variable)</td>
      <td>directories to add to pkg-config's search path</td>
    </tr>
    <tr>
      <td>PKG_CONFIG_LIBDIR=&quot;...&quot;</td>
      <td></td>
      <td></td>
      <td>path overriding pkg-config's built-in search path</td>
    </tr>
  </tbody>
</table>

When running `make VAR=VALUE` commands, the following environment variables can
be used:

| make with Autotools   | CMake                            | Default value/notes           |
| --------------------- | -------------------------------- | ----------------------------- |
| `EXTRA_CFLAGS="..."`  |                                  | Append additional CFLAGS      |
| `EXTRA_LDFLAGS="..."` |                                  | Append additional LDFLAGS     |
| `INSTALL_ROOT=...`    | `DESTDIR=...`                    | Override the installation dir |
|                       | or `DESTDIR=... cmake --install` |                               |
