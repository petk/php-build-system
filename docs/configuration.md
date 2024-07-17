# PHP build system configuration

## Index

* [1. CMake presets](#1-cmake-presets)
* [2. CMake configuration](#2-cmake-configuration)
* [3. PHP configuration](#3-php-configuration)
* [4. Zend engine configuration](#4-zend-engine-configuration)
* [5. PHP SAPI modules configuration](#5-php-sapi-modules-configuration)
* [6. PHP extensions configuration](#6-php-extensions-configuration)
* [7. CMake GUI](#7-cmake-gui)
* [8. Command-line interface ccmake](#8-command-line-interface-ccmake)
* [9. Configuration options mapping: Autotools, Windows JScript, and CMake](#9-configuration-options-mapping-autotools-windows-jscript-and-cmake)

Build configuration can be passed on the command line at the configuration
phase with the `-D` options:

```sh
cmake -DCMAKE_FOO=ON -DPHP_BAR -DZEND_BAZ -DEXT_NAME=ON ... -S php-src -B php-build
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

* `<PackageName>_ROOT` variables

  Path where to look for `PackageName`, when calling the
  `find_package(<PackageName> ...)` command.

  ```sh
  cmake -DIconv_ROOT=/path/to/libiconv -DSQLite3_ROOT=/path/to/sqlite3 -S php-src -B php-build
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

* `CMAKE_EXPORT_COMPILE_COMMANDS=OFF|ON`

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

* `CMAKE_LINKER_TYPE` (CMake 3.29+)

  Default empty

  Specify which linker will be used for the link step.

  ```sh
  # For example, to use the mold linker:
  cmake -S php-src -B php-build -DCMAKE_LINKER_TYPE=MOLD
  ```

* `CMAKE_MESSAGE_CONTEXT_SHOW=OFF|ON`

  Default: `OFF`

  Show/hide context in configuration log ([ext/foo] Checking for...).

* `BUILD_SHARED_LIBS=OFF|ON`

  Default: `OFF`

  Build all enabled PHP extensions as shared libraries.

* `CMAKE_SKIP_RPATH=OFF|ON`

  Default: `OFF`

  Controls whether to add additional runtime library search paths (runpaths or
  rpath) to executables in build directory and installation directory. These are
  passed in form of `-Wl,-rpath,/additional/path/to/library` at build time.

  See the RUNPATH in the executable:

  ```sh
  objdump -x ./php-src/sapi/cli/php | grep 'R.*PATH'
  ```

  * `CMAKE_SKIP_BUILD_RPATH=OFF|ON`

    Default: `OFF`

    Disable runtime library search paths (rpath) in build directory executables.

  * `CMAKE_SKIP_INSTALL_RPATH=OFF|ON`

    Default: `OFF`

    Disable runtime library search paths (rpath) in installation directory
    executables.

## 3. PHP configuration

* `PHP_RE2C_CGOTO=OFF|ON`

  Default: `OFF`

  Enable the goto C statements when using re2c.

* `PHP_BUILD_ARCH`

  Default: `${CMAKE_SYSTEM_PROCESSOR}`

  Build target architecture displayed in phpinfo.

* `PHP_BUILD_COMPILER`

  Default: `${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}`

  Compiler used for build displayed in phpinfo.

* `PHP_BUILD_PROVIDER`

  Default empty

  Build provider displayed in phpinfo.

* `SED_EXECUTABLE`

  Default path to the sed on the host system.

  Path to the sed, which can be manually overridden to the sed on the target
  system. This is only used in generated phpize (and php-config) scripts on *nix
  systems.

* `PHP_CCACHE=ON|OFF`

  Default: `ON`

  If ccache is installed on the system it will be used for faster compilation
  time. If not found, it is not used. It can be explicitly turned off with this
  option or by setting environment variable `CCACHE_DISABLE=1`. A custom path to
  the `ccache` installation directory can be also set with the `Ccache_ROOT`.

## 4. Zend engine configuration

## 5. PHP SAPI modules configuration

## 6. PHP extensions configuration

* `EXT_ODBC=OFF|ON`

  Default: `OFF`

  Whether to enable the odbc extension.

  * `EXT_ODBC_TYPE`

    Default: `unixODBC`

    Select the ODBC type. Can be `adabas`, `dbmaker`, `empress-bcs`, `empress`,
    `esoob`, `ibm-db2`, `iODBC`, `sapdb`, `solid`, `unixODBC`, or `generic`.

  * `EXT_ODBC_VERSION`

    Force support for the passed ODBC version. A hex number is expected. Set it
    to empty value to prevent an explicit ODBCVER to be defined. By default it
    is set to the highest supported ODBC version by PHP.

* `EXT_PDO_MYSQL=OFF|ON`

  Default: `OFF`

  Whether to enable the pdo_mysql extension.

  * `EXT_PDO_MYSQL_DRIVER=mysqlnd|mysql`

    Default: `mysqlnd`

    Select the MySQL driver for pdo_mysql extension.

* `EXT_PDO_ODBC=OFF|ON`

  Default: `OFF`

  Whether to enable the pdo_odbc extension.

  * `EXT_PDO_ODBC_TYPE=ibm-db2|iODBC|unixODBC|generic`

    Default: `unixODBC`

    Select the ODBC type.

  * `EXT_PDO_ODBC_ROOT`

    Path to the ODBC library root directory.

  * `EXT_PDO_ODBC_LIBRARY`

    Set the ODBC library name.

  * `EXT_PDO_ODBC_CFLAGS`

    A list of additional ODBC library compile flags.

  * `EXT_PDO_ODBC_LDFLAGS`

    A list of additional ODBC library linker flags.

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
      <td>PHP_RE2C_CGOTO=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-re2c-cgoto</td>
      <td>N/A</td>
      <td>PHP_RE2C_CGOTO=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-debug</td>
      <td>--disable-debug</td>
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
      <td>N/A</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-debug-assertions</td>
      <td>N/A</td>
      <td>
        Single configuration generators: <code>CMAKE_BUILD_TYPE=DebugAssertions</code><br>
        Multi configuration generators: <code>cmake --build dir --config DebugAssertions</code>
      </td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-debug-pack</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-debug-pack</td>
      <td></td>
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
      <td></td>
      <td>PHP_USE_RTLD_NOW=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-rtld-now</td>
      <td></td>
      <td>PHP_USE_RTLD_NOW=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-short-tags</td>
      <td>N/A</td>
      <td>PHP_SHORT_TAGS=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-short-tags</td>
      <td>N/A</td>
      <td>PHP_SHORT_TAGS=OFF</td>
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
      <td></td>
      <td>PHP_DTRACE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dtrace</td>
      <td></td>
      <td>PHP_DTRACE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fd-setsize</td>
      <td></td>
      <td>PHP_FD_SETSIZE=""</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-fd-setsize=NUM</td>
      <td></td>
      <td>PHP_FD_SETSIZE=NUM</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-valgrind</td>
      <td></td>
      <td>PHP_VALGRIND=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-valgrind<br>
        &emsp;[VALGRIND_CFLAGS=...]<br>
        &emsp;[VALGRIND_LIBS=...]
      </td>
      <td></td>
      <td>
        PHP_VALGRIND=ON<br>
        [Valgrind_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--with-libdir=NAME</td>
      <td></td>
      <td>CMAKE_INSTALL_LIBDIR=NAME</td>
      <td>See GNUInstallDirs</td>
    </tr>
    <tr>
      <td>--with-layout=PHP|GNU</td>
      <td></td>
      <td>PHP_LAYOUT=PHP|GNU</td>
      <td>default: PHP</td>
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
      <td></td>
      <td>PHP_DMALLOC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dmalloc</td>
      <td></td>
      <td>
        PHP_DMALLOC=ON<br>
        [Dmalloc_ROOT=DIR]
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
      <td>default (only for *nix)</td>
    </tr>
    <tr>
      <td>&emsp;--with-config-file-path=PATH</td>
      <td>N/A</td>
      <td>PHP_CONFIG_FILE_PATH=PATH</td>
      <td>(only for *nix)</td>
    </tr>
    <tr>
      <td>--disable-gcov</td>
      <td></td>
      <td>PHP_GCOV=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-gcov</td>
      <td></td>
      <td>
        PHP_GCOV=ON<br>
        [Gcov_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-rpath</td>
      <td></td>
      <td>
        CMAKE_SKIP_RPATH=OFF<br>
        CMAKE_SKIP_INSTALL_RPATH=OFF<br>
        CMAKE_SKIP_BUILD_RPATH=OFF
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-rpath</td>
      <td></td>
      <td>
        CMAKE_SKIP_RPATH=ON<br>
        or CMAKE_SKIP_INSTALL_RPATH=ON<br>
        and/or CMAKE_SKIP_BUILD_RPATH=ON
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-libgcc</td>
      <td></td>
      <td>PHP_LIBGCC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-libgcc</td>
      <td></td>
      <td>PHP_LIBGCC=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-all</td>
      <td></td>
      <td>Use <code>cmake --preset all-enabled</code></td>
      <td>Enables all extensions and some additional configuration</td>
    </tr>
    <tr>
      <td>--disable-all</td>
      <td></td>
      <td>Use <code>cmake --preset all-disabled</code></td>
      <td>Disables all extensions and some additional configuration</td>
    </tr>
    <tr>
      <th colspan="4">Zend engine configuration</td>
    </tr>
    <tr>
      <td>--enable-gcc-global-regs</td>
      <td>N/A</td>
      <td>ZEND_GCC_GLOBAL_REGS=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-gcc-global-regs</td>
      <td>N/A</td>
      <td>ZEND_GCC_GLOBAL_REGS=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fiber-asm</td>
      <td>N/A</td>
      <td>ZEND_FIBER_ASM=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-fiber-asm</td>
      <td>N/A</td>
      <td>ZEND_FIBER_ASM=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-zend-signals</td>
      <td>N/A</td>
      <td>ZEND_SIGNALS=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-zend-signals</td>
      <td>N/A</td>
      <td>ZEND_SIGNALS=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zend-max-execution-timers</td>
      <td>N/A</td>
      <td>ZEND_MAX_EXECUTION_TIMERS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-zend-max-execution-timers</td>
      <td>N/A</td>
      <td>ZEND_MAX_EXECUTION_TIMERS=ON</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">PHP SAPI modules configuration</th>
    </tr>
    <tr>
      <td>--without-apxs2</td>
      <td>--disable-apache2handler or --disable-apache2-4handler</td>
      <td>SAPI_APACHE2HANDLER=OFF</td>
      <td>
        default, in PHP >= 8.4 <code>--disable-apache2handler</code> is for
        Apache 2.4 and not Apache 2.0 anymore</td>
    </tr>
    <tr>
      <td>&emsp;--with-apxs2[=PATH_TO_APXS]</td>
      <td>--enable-apache2handler or --enable-apache2-4handler</td>
      <td>
        SAPI_APACHE2HANDLER=ON<br>
        [Apache_ROOT=PATH_TO_APACHE]<br>
        [Apache_APXS_EXECUTABLE=PATH_TO_APXS]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-apache2handler</td>
      <td>N/A</td>
      <td>default, in PHP <= 8.3 this was for Apache 2.0</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-apache2handler</td>
      <td>N/A</td>
      <td>in PHP <= 8.3 this was for Apache 2.0</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-apache2-2handler</td>
      <td>N/A</td>
      <td>default, removed since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-apache2-2handler</td>
      <td>N/A</td>
      <td>removed since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>--enable-cgi</td>
      <td>--enable-cgi</td>
      <td>SAPI_CGI=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-cgi</td>
      <td>--disable-cgi</td>
      <td>SAPI_CGI=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-cli</td>
      <td>--enable-cli</td>
      <td>SAPI_CLI=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-cli</td>
      <td>--disable-cli</td>
      <td>SAPI_CLI=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td>--disable-cli-win32</td>
      <td>SAPI_CLI_WIN_NO_CONSOLE=OFF</td>
      <td>default; Windows only</td>
    </tr>
    <tr>
      <td></td>
      <td>--enable-cli-win32</td>
      <td>SAPI_CLI_WIN_NO_CONSOLE=ON</td>
      <td>Windows only</td>
    </tr>
    <tr>
      <td>--disable-embed</td>
      <td>--disable-embed</td>
      <td>SAPI_EMBED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-embed</td>
      <td>--enable-embed</td>
      <td>SAPI_EMBED=ON</td>
      <td>will be build as shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-embed=shared</td>
      <td>N/A</td>
      <td>
        SAPI_EMBED=ON<br>
        SAPI_EMBED_SHARED=ON
      </td>
      <td>will be build as shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-embed=static</td>
      <td>--enable-embed</td>
      <td>
        SAPI_EMBED=ON<br>
        SAPI_EMBED_SHARED=OFF
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fpm</td>
      <td>N/A</td>
      <td>SAPI_FPM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-fpm</td>
      <td>N/A</td>
      <td>SAPI_FPM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;[--with-fpm-user=USER]</td>
      <td>N/A</td>
      <td>[SAPI_FPM_USER=USER]</td>
      <td>default: nobody</td>
    </tr>
    <tr>
      <td>&emsp;[--with-fpm-group=GROUP]</td>
      <td>N/A</td>
      <td>[SAPI_FPM_GROUP=GROUP]</td>
      <td>default: nobody</td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-systemd</td>
      <td>N/A</td>
      <td>SAPI_FPM_SYSTEMD=OFF</td>
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
        SAPI_FPM_SYSTEMD=ON<br>
        [Systemd_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-acl</td>
      <td>N/A</td>
      <td>SAPI_FPM_ACL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-fpm-acl</td>
      <td>N/A</td>
      <td>
        SAPI_FPM_ACL=ON<br>
        [ACL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-apparmor</td>
      <td>N/A</td>
      <td>SAPI_FPM_APPARMOR=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-fpm-apparmor</td>
      <td>N/A</td>
      <td>
        SAPI_FPM_APPARMOR=ON<br>
        [AppArmor_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-fpm-selinux</td>
      <td>N/A</td>
      <td>SAPI_FPM_SELINUX=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-fpm-selinux</td>
      <td>N/A</td>
      <td>
        SAPI_FPM_SELINUX=ON<br>
        [SELinux_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-fuzzer</td>
      <td>N/A</td>
      <td>SAPI_FUZZER=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--enable-fuzzer<br>
        &emsp;[LIB_FUZZING_ENGINE=...]
      </td>
      <td>N/A</td>
      <td>SAPI_FUZZER=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-litespeed</td>
      <td>N/A</td>
      <td>SAPI_LITESPEED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-litespeed</td>
      <td>N/A</td>
      <td>SAPI_LITESPEED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-phpdbg</td>
      <td>--enable-phpdbg</td>
      <td>SAPI_PHPDBG=ON</td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-phpdbg</td>
      <td>--disable-phpdbg</td>
      <td>SAPI_PHPDBG=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-phpdbg-debug</td>
      <td>--disable-phpdbg-debug</td>
      <td>SAPI_PHPDBG_DEBUG=OFF</td>
      <td>default (on Windows since PHP >= 8.4)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-phpdbg-debug</td>
      <td>--enable-phpdbg-debug</td>
      <td>SAPI_PHPDBG_DEBUG=ON</td>
      <td>(on Windows since PHP >= 8.4)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-phpdbg-readline</td>
      <td>N/A</td>
      <td>SAPI_PHPDBG_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-phpdbg-readline</td>
      <td>N/A</td>
      <td>SAPI_PHPDBG_READLINE=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-phpdbgs</td>
      <td>SAPI_PHPDBG_SHARED=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-phpdbgs</td>
      <td>SAPI_PHPDBG_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">PHP extensions</th>
    </tr>
    <tr>
      <td>--disable-bcmath</td>
      <td>--disable-bcmath</td>
      <td>EXT_BCMATH=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-bcmath</td>
      <td>--enable-bcmath</td>
      <td>EXT_BCMATH=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-bcmath=shared</td>
      <td>--enable-bcmath=shared</td>
      <td>EXT_BCMATH_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-bz2</td>
      <td>--without-bz2</td>
      <td>EXT_BZ2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-bz2[=DIR]</td>
      <td>--with-bz2</td>
      <td>
        EXT_BZ2=ON<br>
        [BZip2_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-bz2=shared</td>
      <td>--with-bz2=shared</td>
      <td>EXT_BZ2_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-calendar</td>
      <td>--disable-calendar</td>
      <td>EXT_CALENDAR=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-calendar</td>
      <td>--enable-calendar</td>
      <td>EXT_CALENDAR=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-calendar=shared</td>
      <td>--enable-calendar=shared</td>
      <td>EXT_CALENDAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-com-dotnet</td>
      <td>EXT_COM_DOTNET=ON</td>
      <td>default; Windows only</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-com-dotnet=shared</td>
      <td>EXT_COM_DOTNET_SHARED=ON</td>
      <td>Windows only</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-com-dotnet</td>
      <td>EXT_COM_DOTNET=OFF</td>
      <td>Windows only</td>
    </tr>
    <tr>
      <td>--enable-ctype</td>
      <td>--enable-ctype</td>
      <td>EXT_CTYPE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-ctype=shared</td>
      <td>--enable-ctype=shared</td>
      <td>EXT_CTYPE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-ctype</td>
      <td>--disable-ctype</td>
      <td>EXT_CTYPE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-curl</td>
      <td>--without-curl</td>
      <td>EXT_CURL=OFF</td>
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
        EXT_CURL=ON<br>
        [CURL_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-curl=shared</td>
      <td>--with-curl=shared</td>
      <td>EXT_CURL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dba</td>
      <td></td>
      <td>EXT_DBA=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dba</td>
      <td></td>
      <td>EXT_DBA=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-dba=shared</td>
      <td></td>
      <td>EXT_DBA_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-flatfile</td>
      <td></td>
      <td>EXT_DBA_FLATFILE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--without-flatfile</td>
      <td></td>
      <td>EXT_DBA_FLATFILE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-inifile</td>
      <td></td>
      <td>EXT_DBA_INIFILE=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--without-inifile</td>
      <td></td>
      <td>EXT_DBA_INIFILE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-qdbm</td>
      <td></td>
      <td>EXT_DBA_QDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-qdbm[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_QDBM=ON<br>
        [QDBM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-gdbm</td>
      <td></td>
      <td>EXT_DBA_GDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-gdbm[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_GDBM=ON<br>
        [GDBM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ndbm</td>
      <td></td>
      <td>EXT_DBA_NDBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-ndbm[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_NDBM=ON<br>
        [Ndbm_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db4</td>
      <td></td>
      <td>EXT_DBA_DB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db4[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_DB=ON<br>
        [BerkeleyDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db3</td>
      <td></td>
      <td>EXT_DBA_DB3=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db3</td>
      <td></td>
      <td>EXT_DBA_DB3=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db2</td>
      <td></td>
      <td>EXT_DBA_DB2=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db2</td>
      <td></td>
      <td>EXT_DBA_DB2=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-db1</td>
      <td></td>
      <td>EXT_DBA_DB1=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-db1</td>
      <td></td>
      <td>EXT_DBA_DB1=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-dbm</td>
      <td></td>
      <td>EXT_DBA_DBM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-dbm[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_DBM=ON<br>
        [Dbm_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-tcadb</td>
      <td></td>
      <td>EXT_DBA_TCADB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-tcadb[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_TCADB=ON<br>
        [TokyoCabinet_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-lmdb</td>
      <td></td>
      <td>EXT_DBA_LMDB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-lmdb[=DIR]</td>
      <td></td>
      <td>
        EXT_DBA_LMDB=ON<br>
        [LMDB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-cdb</td>
      <td></td>
      <td>EXT_DBA_CDB=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-cdb=DIR</td>
      <td></td>
      <td>
        EXT_DBA_CDB_EXTERNAL=ON<br>
        Cdb_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-cdb</td>
      <td></td>
      <td>EXT_DBA_CDB=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-dl-test</td>
      <td>--disable-dl-test</td>
      <td>EXT_DL_TEST=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dl-test</td>
      <td>--enable-dl-test</td>
      <td>EXT_DL_TEST=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dl-test=shared</td>
      <td>--enable-dl-test=shared</td>
      <td>EXT_DL_TEST=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>--enable-dom</td>
      <td>--enable-dom</td>
      <td>EXT_DOM=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-dom=shared</td>
      <td>--enable-dom=shared</td>
      <td>EXT_DOM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-dom</td>
      <td>--disable-dom</td>
      <td>EXT_DOM=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-enchant</td>
      <td>--without-enchant</td>
      <td>EXT_ENCHANT=OFF</td>
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
        EXT_ENCHANT=ON<br>
        [Enchant_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-enchant=shared</td>
      <td>--with-enchant=shared</td>
      <td>EXT_ENCHANT_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-exif</td>
      <td>--disable-exif</td>
      <td>EXT_EXIF=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-exif</td>
      <td>--enable-exif</td>
      <td>EXT_EXIF=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-exif=shared</td>
      <td>--enable-exif=shared</td>
      <td>EXT_EXIF_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-ffi</td>
      <td>--without-ffi</td>
      <td>EXT_FFI=OFF</td>
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
        EXT_FFI=ON<br>
        [FFI_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-ffi=shared</td>
      <td>--with-ffi=shared</td>
      <td>EXT_FFI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-fileinfo</td>
      <td>--enable-fileinfo</td>
      <td>EXT_FILEINFO=ON</td>
      <td>default in *nix and Cmake (on Windows by default disabled and can be only shared)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-fileinfo=shared</td>
      <td>--enable-fileinfo=shared</td>
      <td>EXT_FILEINFO_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-fileinfo</td>
      <td>--disable-fileinfo</td>
      <td>EXT_FILEINFO=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-filter</td>
      <td>--enable-filter</td>
      <td>EXT_FILTER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-filter=shared</td>
      <td>--enable-filter=shared</td>
      <td>EXT_FILTER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-filter</td>
      <td>--disable-filter</td>
      <td>EXT_FILTER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-ftp</td>
      <td>--disable-ftp</td>
      <td>EXT_FTP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-ftp</td>
      <td>--enable-ftp</td>
      <td>EXT_FTP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-ftp=shared</td>
      <td>--enable-ftp=shared</td>
      <td>EXT_FTP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ftp-ssl</td>
      <td>N/A</td>
      <td>EXT_FTP_SSL=OFF</td>
      <td>default, PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-ftp-ssl</td>
      <td>N/A</td>
      <td>EXT_FTP_SSL=ON</td>
      <td>PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--without-openssl-dir</td>
      <td>N/A</td>
      <td>EXT_FTP_SSL=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl-dir</td>
      <td>N/A</td>
      <td>EXT_FTP_SSL=ON</td>
      <td>PHP <= 8.3</td>
    </tr>
    <tr>
      <td>--disable-gd</td>
      <td></td>
      <td>EXT_GD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-gd</td>
      <td></td>
      <td>EXT_GD=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-gd=shared</td>
      <td></td>
      <td>EXT_GD_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-external-gd</td>
      <td></td>
      <td>EXT_GD_EXTERNAL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-external-gd<br>
        &emsp;[GDLIB_CFLAGS=...]<br>
        &emsp;[GDLIB_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_GD_EXTERNAL=ON<br>
        [GD_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-avif</td>
      <td></td>
      <td>EXT_GD_AVIF=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-avif<br>
        &emsp;[AVIF_CFLAGS=...]<br>
        &emsp;[AVIF_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_GD_AVIF=ON<br>
        [libavif_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-webp</td>
      <td></td>
      <td>EXT_GD_WEBP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-webp<br>
        &emsp;[WEBP_CFLAGS=...]<br>
        &emsp;[WEBP_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_GD_WEBP=ON<br>
        [WebP_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-jpeg</td>
      <td></td>
      <td>EXT_GD_JPEG=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-jpeg<br>
        &emsp;[JPEG_CFLAGS=...]<br>
        &emsp;[JPEG_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_GD_JPEG=ON<br>
        [JPEG_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>
        &emsp;[PNG_CFLAGS=...]<br>
        &emsp;[PNG_LIBS=...]
      </td>
      <td></td>
      <td>
        [PNG_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-xpm</td>
      <td></td>
      <td>EXT_GD_XPM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-xpm<br>
        &emsp;[XPM_CFLAGS=...]<br>
        &emsp;[XPM_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_GD_XPM=ON<br>
        [XPM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-freetype</td>
      <td></td>
      <td>EXT_GD_FREETYPE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-freetype<br>
        &emsp;[FREETYPE2_CFLAGS=...]<br>
        &emsp;[FREETYPE2_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_GD_FREETYPE=ON<br>
        [Freetype_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-gd-jis-conv</td>
      <td></td>
      <td>EXT_GD_JIS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-gd-jis-conv</td>
      <td></td>
      <td>EXT_GD_JIS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-gettext</td>
      <td></td>
      <td>EXT_GETTEXT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-gettext[=DIR]</td>
      <td></td>
      <td>
        EXT_GETTEXT=ON<br>
        [Intl_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-gettext=shared</td>
      <td></td>
      <td>EXT_GETTEXT_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-gmp</td>
      <td></td>
      <td>EXT_GMP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-gmp[=DIR]</td>
      <td></td>
      <td>
        EXT_GMP=ON<br>
        [GMP_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-gmp=shared</td>
      <td></td>
      <td>EXT_GMP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mhash</td>
      <td>--without-mhash</td>
      <td>EXT_HASH_MHASH=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-mhash</td>
      <td>--with-mhash</td>
      <td>EXT_HASH_MHASH=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--with-iconv[=DIR]</td>
      <td></td>
      <td>
        EXT_ICONV=ON<br>
        [Iconv_ROOT=DIR]
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-iconv=shared</td>
      <td></td>
      <td>EXT_ICONV_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-iconv</td>
      <td></td>
      <td>EXT_ICONV=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-imap</td>
      <td>--without-imap</td>
      <td>EXT_IMAP=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-imap[=DIR]</td>
      <td>--with-imap</td>
      <td>
        EXT_IMAP=ON<br>
        [Cclient_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-kerberos</td>
      <td>N/A</td>
      <td>EXT_IMAP_KERBEROS=OFF</td>
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
        EXT_IMAP_KERBEROS=ON<br>
        [Kerberos_ROOT=...]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-imap-ssl</td>
      <td>N/A</td>
      <td>EXT_IMAP_SSL=OFF</td>
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
        EXT_IMAP_SSL=ON<br>
        [OPENSSL_ROOT_DIR=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-intl</td>
      <td></td>
      <td>EXT_INTL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--enable-intl<br>
        &emsp;[ICU_CFLAGS=...]<br>
        &emsp;[ICU_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_INTL=ON<br>
        [ICU_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-intl=shared</td>
      <td></td>
      <td>EXT_INTL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-ldap</td>
      <td></td>
      <td>EXT_LDAP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-ldap[=DIR]
      </td>
      <td></td>
      <td>
        EXT_LDAP=ON<br>
        [LDAP_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-ldap=shared</td>
      <td></td>
      <td>EXT_LDAP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ldap-sasl</td>
      <td></td>
      <td>EXT_LDAP_SASL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-ldap-sasl<br>
        &emsp;[SASL_CFLAGS=...]<br>
        &emsp;[SASL_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_LDAP_SASL=ON<br>
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
        EXT_LIBXML=ON<br>
        [LibXml2_ROOT=DIR]
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--without-libxml</td>
      <td>--without-libxml</td>
      <td>EXT_LIBXML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-mbstring</td>
      <td>--disable-mbstring</td>
      <td>EXT_MBSTRING=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-mbstring</td>
      <td>--enable-mbstring</td>
      <td>EXT_MBSTRING=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-mbstring=shared</td>
      <td>--enable-mbstring=shared</td>
      <td>EXT_MBSTRING_SHARED=ON</td>
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
        EXT_MBSTRING_MBREGEX=ON<br>
        [Oniguruma_ROOT=DIR]
      </td>
      <td>default in *nix and CMake (on Windows disabled)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-mbregex</td>
      <td>--disable-mbregex</td>
      <td>EXT_MBSTRING_MBREGEX=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysqli</td>
      <td>--without-mysqli</td>
      <td>EXT_MYSQLI=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-mysqli</td>
      <td>--with-mysqli</td>
      <td>EXT_MYSQLI=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-mysqli=shared</td>
      <td>--with-mysqli=shared</td>
      <td>EXT_MYSQLI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysql-sock</td>
      <td>N/A</td>
      <td>EXT_MYSQL_SOCKET=OFF</td>
      <td>default, not available on Windows</td>
    </tr>
    <tr>
      <td>&emsp;--with-mysql-sock</td>
      <td>N/A</td>
      <td>EXT_MYSQL_SOCKET=ON</td>
      <td>Not available on Windows</td>
    </tr>
    <tr>
      <td>&emsp;--with-mysql-sock=SOCKET</td>
      <td>N/A</td>
      <td>
        EXT_MYSQL_SOCKET=ON<br>
        EXT_MYSQL_SOCKET_PATH=/path/to/mysql.sock
      </td>
      <td>Not available on Windows</td>
    </tr>
    <tr>
      <td>--disable-mysqlnd</td>
      <td>--without-mysqlnd</td>
      <td>EXT_MYSQLND=OFF</td>
      <td>default in *nix and CMake (on Windows enabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-mysqlnd</td>
      <td>--with-mysqlnd</td>
      <td>EXT_MYSQLND=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-mysqlnd=shared</td>
      <td>N/A</td>
      <td>EXT_MYSQLND_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-mysqlnd-compression-support</td>
      <td>N/A (enabled by default)</td>
      <td>EXT_MYSQLND_COMPRESSION=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-mysqlnd-compression-support</td>
      <td>N/A</td>
      <td>EXT_MYSQLND_COMPRESSION=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-mysqlnd-ssl</td>
      <td>N/A</td>
      <td>EXT_MYSQLND_SSL=OFF</td>
      <td>default, PHP >= 8.4</td>
    </tr>
    <tr>
      <td>--with-mysqlnd-ssl</td>
      <td>N/A</td>
      <td>EXT_MYSQLND_SSL=ON</td>
      <td>PHP >= 8.4</td>
    </tr>
    <tr>
      <td>--without-oci8</td>
      <td>N/A</td>
      <td>EXT_OCI8=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-oci8[=DIR]</td>
      <td>N/A</td>
      <td>
        EXT_OCI8=ON<br>
        [...]
      </td>
      <td>PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-oci8=shared</td>
      <td>N/A</td>
      <td>EXT_OCI8_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--without-oci8-11g</td>
      <td>EXT_OCI8_11G=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-oci8-11g</td>
      <td>EXT_OCI8_11G=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--without-oci8-12c</td>
      <td>EXT_OCI8_12C=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-oci8-12c</td>
      <td>EXT_OCI8_12C=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--without-oci8-19</td>
      <td>EXT_OCI8_19=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--with-oci8-19</td>
      <td>EXT_OCI8_19=ON</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>EXT_ODBC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td>EXT_ODBC=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-odbcver</td>
      <td></td>
      <td>EXT_ODBC_VERSION="0x0350"</td>
      <td>default: 0x0350</td>
    </tr>
    <tr>
      <td>&emsp;--with-odbcver[=HEX]</td>
      <td></td>
      <td>EXT_ODBC_VERSION=HEX</td>
      <td>default: 0x0350</td>
    </tr>
    <tr>
      <td>&emsp;--without-adabas</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-adabas</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=adabas
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-sapdb</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-sapdb</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=sapdb
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-solid</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-solid</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=solid
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-ibm-db2</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-ibm-db2</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=ibm-db2
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-empress</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-empress</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=empress
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-empress-bcs</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-empress-bcs</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=empress-bcs
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-custom-odbc</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-custom-odbc</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=generic
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-iodbc</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-iodbc<br>
        &emsp;[ODBC_CFLAGS=...]<br>
        &emsp;[ODBC_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=iODBC<br>
        [ODBC_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-esoob</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-esoob</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=esoob
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-unixODBC</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-unixODBC<br>
        &emsp;[ODBC_CFLAGS=...]<br>
        &emsp;[ODBC_LIBS=...]
      </td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=unixODBC<br>
        [ODBC_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-dbmaker</td>
      <td></td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-dbmaker</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=dbmaker
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-dbmaker=DIR</td>
      <td></td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=dbmaker<br>
        ODBC_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-opcache</td>
      <td>--enable-opcache</td>
      <td>EXT_OPCACHE=ON</td>
      <td>default, will be shared</td>
    </tr>
    <tr>
      <td>&emsp;--enable-opcache=shared</td>
      <td>--enable-opcache=shared</td>
      <td>EXT_OPCACHE=ON</td>
      <td>will be shared</td>
    </tr>
    <tr>
      <td>&emsp;--disable-opcache</td>
      <td>--disable-opcache</td>
      <td>EXT_OPCACHE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-huge-code-pages</td>
      <td>N/A</td>
      <td>EXT_OPCACHE_HUGE_CODE_PAGES=ON</td>
      <td>default; For non-Windows platforms</td>
    </tr>
    <tr>
      <td>&emsp;--disable-huge-code-pages</td>
      <td>N/A</td>
      <td>EXT_OPCACHE_HUGE_CODE_PAGES=OFF</td>
      <td>For non-Windows platforms</td>
    </tr>
    <tr>
      <td>&emsp;--enable-opcache-jit</td>
      <td>--enable-opcache-jit</td>
      <td>EXT_OPCACHE_JIT=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--disable-opcache-jit</td>
      <td>--disable-opcache-jit</td>
      <td>EXT_OPCACHE_JIT=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-capstone</td>
      <td>N/A</td>
      <td>EXT_OPCACHE_CAPSTONE=OFF</td>
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
        EXT_OPCACHE_CAPSTONE=ON<br>
        [Capstone_ROOT=DIR]
      </td>
      <td>For non-Windows platforms</td>
    </tr>
    <tr>
      <td>--without-openssl</td>
      <td>--without-openssl</td>
      <td>EXT_OPENSSL=OFF</td>
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
        EXT_OPENSSL=ON<br>
        [OPENSSL_ROOT_DIR=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl=shared</td>
      <td>--with-openssl=shared</td>
      <td>EXT_OPENSSL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-openssl-legacy-provider</td>
      <td>N/A</td>
      <td>EXT_OPENSSL_LEGACY_PROVIDER=OFF</td>
      <td>default, PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-openssl-legacy-provider</td>
      <td>N/A</td>
      <td>EXT_OPENSSL_LEGACY_PROVIDER=ON</td>
      <td>PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--without-kerberos</td>
      <td>N/A</td>
      <td>EXT_OPENSSL_KERBEROS=OFF</td>
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
        EXT_OPENSSL_KERBEROS=ON<br>
        [Kerberos_ROOT=DIR]
      </td>
      <td>PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--without-system-ciphers</td>
      <td>N/A</td>
      <td>EXT_OPENSSL_SYSTEM_CIPHERS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-system-ciphers</td>
      <td>N/A</td>
      <td>EXT_OPENSSL_SYSTEM_CIPHERS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-pcntl</td>
      <td>N/A</td>
      <td>EXT_PCNTL=OFF</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-pcntl</td>
      <td>N/A</td>
      <td>EXT_PCNTL=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-pcntl=shared</td>
      <td>N/A</td>
      <td>EXT_PCNTL_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--with-pcre-jit</td>
      <td>--with-pcre-jit</td>
      <td>EXT_PCRE_JIT=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--without-pcre-jit</td>
      <td>--without-pcre-jit</td>
      <td>EXT_PCRE_JIT=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-external-pcre</td>
      <td>N/A</td>
      <td>EXT_PCRE_EXTERNAL=OFF</td>
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
        EXT_PCRE_EXTERNAL=ON<br>
        [PCRE_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-pdo</td>
      <td>--enable-pdo</td>
      <td>EXT_PDO=ON</td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--enable-pdo=shared</td>
      <td>&emsp;--enable-pdo=shared</td>
      <td>EXT_PDO_SHARED=ON</td>
      <td>(on Windows can't be built as shared yet)</td>
    </tr>
    <tr>
      <td>&emsp;--disable-pdo</td>
      <td>&emsp;--disable-pdo</td>
      <td>EXT_PDO=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-dblib</td>
      <td></td>
      <td>EXT_PDO_DBLIB=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>
        &emsp;--with-pdo-dblib[=DIR]
      </td>
      <td></td>
      <td>
        EXT_PDO_DBLIB=ON<br>
        [FreeTDS_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-dblib=shared</td>
      <td></td>
      <td>EXT_PDO_DBLIB_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-firebird</td>
      <td></td>
      <td>EXT_PDO_FIREBIRD=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-firebird[=DIR]</td>
      <td></td>
      <td>
        EXT_PDO_FIREBIRD=ON<br>
        [Firebird_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-firebird=shared</td>
      <td></td>
      <td>EXT_PDO_FIREBIRD_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-mysql</td>
      <td></td>
      <td>EXT_PDO_MYSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql</td>
      <td></td>
      <td>EXT_PDO_MYSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=mysqlnd</td>
      <td></td>
      <td>EXT_PDO_MYSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=shared</td>
      <td></td>
      <td>EXT_PDO_MYSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=/usr</td>
      <td></td>
      <td>
        EXT_PDO_MYSQL=ON<br>
        EXT_PDO_MYSQL_DRIVER=mysql
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=DIR</td>
      <td></td>
      <td>
        EXT_PDO_MYSQL=ON<br>
        EXT_PDO_MYSQL_DRIVER=mysql<br>
        MySQL_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-mysql=path/to/mysql_config</td>
      <td></td>
      <td>
        EXT_PDO_MYSQL=ON<br>
        EXT_PDO_MYSQL_DRIVER=mysql<br>
        MySQL_CONFIG_EXECUTABLE=path/to/mysql_config
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-oci</td>
      <td>&emsp;--without-pdo-oci</td>
      <td>EXT_PDO_OCI=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-oci[=DIR]</td>
      <td>&emsp;--with-pdo-oci[=DIR]</td>
      <td>
        EXT_PDO_OCI=ON<br>
        [...]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-oci=shared</td>
      <td>&emsp;--with-pdo-oci=shared</td>
      <td>EXT_PDO_OCI_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-odbc</td>
      <td></td>
      <td>EXT_PDO_ODBC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-odbc=flavor</td>
      <td></td>
      <td>
        EXT_PDO_ODBC=ON<br>
        EXT_PDO_ODBC_TYPE=flavor
      </td>
      <td>Default flavor: unixODBC</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-odbc=flavor,dir,libname,ldflags,cflags</td>
      <td></td>
      <td>
        EXT_PDO_ODBC=ON<br>
        EXT_PDO_ODBC_TYPE=flavor<br>
        EXT_PDO_ODBC_ROOT=dir<br>
        EXT_PDO_ODBC_LIBRARY=libname<br>
        EXT_PDO_ODBC_LDFLAGS=ldflags<br>
        EXT_PDO_ODBC_CFLAGS=cflags
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-odbc=shared</td>
      <td></td>
      <td>EXT_PDO_ODBC_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-pgsql</td>
      <td>--without-pdo-pgsql</td>
      <td>EXT_PDO_PGSQL=OFF</td>
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
        EXT_PDO_PGSQL=ON<br>
        [PostgreSQL_ROOT=DIR]
      </td>
      <td>Autotools PGSQL_CFLAGS and PGSQL_LIBS available since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-pgsql=shared</td>
      <td>--with-pdo-pgsql=shared</td>
      <td>EXT_PDO_PGSQL_SHARED=ON</td>
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
        EXT_PDO_SQLITE=ON<br>
        [SQLite3_ROOT=DIR]
      </td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--with-pdo-sqlite=shared</td>
      <td>--with-pdo-sqlite=shared</td>
      <td>EXT_PDO_SQLITE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-pdo-sqlite</td>
      <td>--without-pdo-sqlite</td>
      <td>EXT_PDO_SQLITE=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-pgsql</td>
      <td>--without-pgsql</td>
      <td>EXT_PGSQL=OFF</td>
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
        EXT_PGSQL=ON<br>
        [PostgreSQL_ROOT=DIR]
      </td>
      <td>Autotools PGSQL_CFLAGS and PGSQL_LIBS available since PHP >= 8.4</td>
    </tr>
    <tr>
      <td>&emsp;--with-pgsql=shared</td>
      <td>--with-pgsql=shared</td>
      <td>EXT_PGSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-phar</td>
      <td>--enable-phar</td>
      <td>EXT_PHAR=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-phar=shared</td>
      <td>--enable-phar=shared</td>
      <td>EXT_PHAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-phar</td>
      <td>--disable-phar</td>
      <td>EXT_PHAR=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--disable-phar-native-ssl</td>
      <td>EXT_PHAR_SSL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-phar-native-ssl</td>
      <td>EXT_PHAR_SSL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>N/A</td>
      <td>--enable-phar-native-ssl=shared</td>
      <td>EXT_PHAR_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-posix</td>
      <td>N/A</td>
      <td>EXT_POSIX=ON</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-posix=shared</td>
      <td>N/A</td>
      <td>EXT_POSIX_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--disable-posix</td>
      <td>N/A</td>
      <td>EXT_POSIX=OFF</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--without-pspell</td>
      <td></td>
      <td>EXT_PSPELL=OFF</td>
      <td>default, PHP <= 8.3</td>
    </tr>
    <tr>
      <td>&emsp;--with-pspell[=DIR]</td>
      <td></td>
      <td>
        EXT_PSPELL=ON<br>
        [Aspell_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-pspell=shared</td>
      <td></td>
      <td>EXT_PSPELL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-libedit</td>
      <td>--without-readline</td>
      <td>EXT_READLINE=OFF</td>
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
        EXT_READLINE=ON<br>
        [Editline_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-libedit=shared</td>
      <td>--with-readline=shared</td>
      <td>EXT_READLINE_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-readline</td>
      <td>--without-readline</td>
      <td>EXT_READLINE=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-readline[=DIR]</td>
      <td>N/A</td>
      <td>
        EXT_READLINE=ON<br>
        EXT_READLINE_LIBREADLINE=ON<br>
        [Readline_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-readline=shared</td>
      <td>N/A</td>
      <td>
        EXT_READLINE=ON<br>
        EXT_READLINE_SHARED=ON<br>
        EXT_READLINE_LIBREADLINE=ON
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-session</td>
      <td>--enable-session</td>
      <td>EXT_SESSION=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-session=shared</td>
      <td>N/A</td>
      <td>EXT_SESSION_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-session</td>
      <td>--disable-session</td>
      <td>EXT_SESSION=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-mm</td>
      <td>N/A</td>
      <td>EXT_SESSION_MM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-mm[=DIR]</td>
      <td>N/A</td>
      <td>
        EXT_SESSION_MM=ON<br>
        [MM_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-shmop</td>
      <td>--disable-shmop</td>
      <td>EXT_SHMOP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-shmop</td>
      <td>--enable-shmop</td>
      <td>EXT_SHMOP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-shmop=shared</td>
      <td>--enable-shmop=shared</td>
      <td>EXT_SHMOP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-simplexml</td>
      <td>--with-simplexml</td>
      <td>EXT_SIMPLEXML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-simplexml=shared</td>
      <td>--with-simplexml=shared</td>
      <td>EXT_SIMPLEXML_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-simplexml</td>
      <td>--without-simplexml</td>
      <td>EXT_SIMPLEXML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-snmp</td>
      <td></td>
      <td>EXT_SNMP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-snmp[=DIR]</td>
      <td></td>
      <td>
        EXT_SNMP=ON<br>
        [NetSnmp_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-snmp=shared</td>
      <td></td>
      <td>EXT_SNMP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-soap</td>
      <td>--disable-soap</td>
      <td>EXT_SOAP=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-soap</td>
      <td>--enable-soap</td>
      <td>EXT_SOAP=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-soap=shared</td>
      <td>--enable-soap=shared</td>
      <td>EXT_SOAP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sockets</td>
      <td>--disable-sockets</td>
      <td>EXT_SOCKETS=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sockets</td>
      <td>--enable-sockets</td>
      <td>EXT_SOCKETS=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-sockets=shared</td>
      <td>--enable-sockets=shared</td>
      <td>EXT_SOCKETS_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-sodium</td>
      <td>--without-sodium</td>
      <td>EXT_SODIUM=OFF</td>
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
        EXT_SODIUM=ON<br>
        [Sodium_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-sodium=shared</td>
      <td>--with-sodium=shared</td>
      <td>EXT_SODIUM_SHARED=ON</td>
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
        EXT_SQLITE3=ON<br>
        [SQLite3_ROOT=DIR]
      </td>
      <td>default in *nix and CMake (on Windows disabled by default)</td>
    </tr>
    <tr>
      <td>&emsp;--with-sqlite3=shared</td>
      <td>--with-sqlite3=shared</td>
      <td>EXT_SQLITE3_SHARED</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-sqlite3</td>
      <td>--without-sqlite3</td>
      <td>EXT_SQLITE3=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-external-libcrypt</td>
      <td>N/A</td>
      <td>EXT_STANDARD_EXTERNAL_LIBCRYPT=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-external-libcrypt</td>
      <td>N/A</td>
      <td>EXT_STANDARD_EXTERNAL_LIBCRYPT=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-password-argon2</td>
      <td>--without-password-argon2</td>
      <td>EXT_STANDARD_ARGON2=OFF</td>
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
        EXT_STANDARD_ARGON2=ON<br>
        [Argon2_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-sysvmsg</td>
      <td>N/A</td>
      <td>EXT_SYSVMSG=OFF</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvmsg</td>
      <td>N/A</td>
      <td>EXT_SYSVMSG=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvmsg=shared</td>
      <td>N/A</td>
      <td>EXT_SYSVMSG_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--disable-sysvsem</td>
      <td>N/A</td>
      <td>EXT_SYSVSEM=OFF</td>
      <td>default; for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvsem</td>
      <td>N/A</td>
      <td>EXT_SYSVSEM=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvsem=shared</td>
      <td>N/A</td>
      <td>EXT_SYSVSEM_SHARED=ON</td>
      <td>for *nix platforms only</td>
    </tr>
    <tr>
      <td>--disable-sysvshm</td>
      <td>--disable-sysvshm</td>
      <td>EXT_SYSVSHM=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvshm</td>
      <td>--enable-sysvshm</td>
      <td>EXT_SYSVSHM=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-sysvshm=shared</td>
      <td>--enable-sysvshm=shared</td>
      <td>EXT_SYSVSHM_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-tidy</td>
      <td></td>
      <td>EXT_TIDY=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-tidy[=DIR]</td>
      <td></td>
      <td>
        EXT_TIDY=ON<br>
        [Tidy_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-tidy=shared</td>
      <td></td>
      <td>EXT_TIDY_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-tokenizer</td>
      <td>--enable-tokenizer</td>
      <td>EXT_TOKENIZER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-tokenizer=shared</td>
      <td>--enable-tokenizer=shared</td>
      <td>EXT_TOKENIZER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-tokenizer</td>
      <td>--disable-tokenizer</td>
      <td>EXT_TOKENIZER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xml</td>
      <td>--with-xml</td>
      <td>EXT_XML=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-xml=shared</td>
      <td>--with-xml=shared</td>
      <td>EXT_XML_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-xml</td>
      <td>--without-xml</td>
      <td>EXT_XML=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--without-expat</td>
      <td>N/A</td>
      <td>EXT_XML_EXPAT=OFF</td>
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
        EXT_XML_EXPAT=ON<br>
        [EXPAT_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xmlreader</td>
      <td>--enable-xmlreader</td>
      <td>EXT_XMLREADER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-xmlreader=shared</td>
      <td>--enable-xmlreader=shared</td>
      <td>EXT_XMLREADER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-xmlreader</td>
      <td>--disable-xmlreader</td>
      <td>EXT_XMLREADER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--enable-xmlwriter</td>
      <td>--enable-xmlwriter</td>
      <td>EXT_XMLWRITER=ON</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-xmlwriter=shared</td>
      <td>--enable-xmlwriter=shared</td>
      <td>EXT_XMLWRITER_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--disable-xmlwriter</td>
      <td>--disable-xmlwriter</td>
      <td>EXT_XMLWRITER=OFF</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-xsl</td>
      <td>--without-xsl</td>
      <td>EXT_XSL=OFF</td>
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
        EXT_XSL=ON<br>
        [LibXslt_ROOT=DIR]<br>
        [CMAKE_PREFIX_PATH=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-xsl=shared</td>
      <td>--with-xsl=shared</td>
      <td>EXT_XSL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--disable-zend-test</td>
      <td>--disable-zend-test</td>
      <td>EXT_ZEND_TEST=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--enable-zend-test</td>
      <td>--enable-zend-test</td>
      <td>EXT_ZEND_TEST=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--enable-zend-test=shared</td>
      <td>--enable-zend-test=shared</td>
      <td>EXT_ZEND_TEST_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-zip</td>
      <td>--disable-zip</td>
      <td>EXT_ZIP=OFF</td>
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
        EXT_ZIP=ON<br>
        libzip_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-zip=shared</td>
      <td>--enable-zip=shared</td>
      <td>EXT_ZIP_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>--without-zlib</td>
      <td>--disable-zlib</td>
      <td>EXT_ZLIB=OFF</td>
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
        EXT_ZLIB=ON<br>
        [ZLIB_ROOT=DIR]
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&emsp;--with-zlib=shared</td>
      <td>--enable-zlib=shared</td>
      <td>EXT_ZLIB_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <th colspan="4">PEAR configuration</th>
    </tr>
    <tr>
      <td>--without-pear</td>
      <td></td>
      <td>PHP_PEAR=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&emsp;--with-pear[=DIR]</td>
      <td></td>
      <td>
        PHP_PEAR=ON<br>
        [PHP_PEAR_DIR=DIR]
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

| make with Autotools   | CMake                         | Default value/notes           |
| --------------------- | ----------------------------- | ----------------------------- |
| `EXTRA_CFLAGS="..."`  |                               | Append additional CFLAGS      |
| `EXTRA_LDFLAGS="..."` |                               | Append additional LDFLAGS     |
| `INSTALL_ROOT="..."`  | `CMAKE_INSTALL_PREFIX="..."`  | Override the installation dir |
|                       | or `cmake --install --prefix` |                               |
