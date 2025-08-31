#[=============================================================================[
# The odbc extension

Configure the `odbc` extension.

This extension provides support for Unified Open Database Connectivity (ODBC)
databases.

## PHP_EXT_ODBC

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `odbc` extension.

## PHP_EXT_ODBC_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_ODBC_TYPE

Select the ODBC type.

Default: `auto`

Values:
  * `auto` - Use this type to find Windows ODBC implementation, unixODBC, iODBC,
    or similar automatically. First found library will be used.
  * `adabas` - When using Adabas database management system.
  * `dbmaker` - When using [DBMaker](https://www.dbmaker.com/).
  * `empress-bcs` - Empress Local Access support, required Empress version is
    8.60 or newer.
  * `empress` - Empress support, required Empress version is 8.60 or newer.
  * `esoob` - Easysoft ODBC-ODBC Bridge support
  * `ibm-db2` - IBM DB2 support.
  * `iODBC` - Independent Open Database Connectivity library
  * `sapdb` - SAP DB support.
  * `solid` - Solid DB support.
  * `unixODBC` - Open Database Connectivity library for *nix systems
  * `custom` - Use this type when using a custom ODBC implementation that cannot
    be found automatically and to manually adjust the compilation options.
    Unlike other special types, PHP code here expects ODBC implementation with
    `<odbc.h>` header.

When using type other than `auto`, `iODBC`, or `unixODBC`, the `ODBC_LIBRARY`
needs to be set manually to find the ODBC library.

For example:

```sh
cmake -S . -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
```

Where to find the installed ODBC library on the system, or to customize ODBC
compile definitions, options, or linker flags can be done with the following
variables:

* `ODBC_COMPILE_DEFINITIONS` - additional compile definitions
* `ODBC_COMPILE_OPTIONS` - additional compile options
* `ODBC_INCLUDE_DIR` - path with the ODBC include header files
* `ODBC_LIBRARY` - ODBC library name or absolute path to the ODBC library
* `ODBC_LINK_OPTIONS` - additional linker options
* `ODBC_ROOT` - the base root directory of the ODBC installation

For example, when using Sybase SQL Anywhere 5.5.00 on QNX:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=<path-to-libodbc.so> \
  -D ODBC_INCLUDE_DIR=... \
  -D ODBC_COMPILE_DEFINITIONS="-DODBC_QNX -DSQLANY_BUG" \
  -D ODBC_LINK_OPTIONS="-lunix -ldblib"
```

For Adabas:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=adabas \
  -D ODBC_ROOT=/path/to/adabas \
  -D ODBC_LIBRARY=odbc_adabas \
  -D ODBC_INCLUDE_DIR=/path/to/adabas/incl \
  -D ODBC_LINK_OPTIONS="-lsqlptc -lsqlrte"
```

For DBMaker:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=dbmaker \
  -D ODBC_ROOT=/path/to/dbmaker \
  -D ODBC_LIBRARY=dmapic \
```

For Easysoft OOB support:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=esoob \
  -D ODBC_ROOT=/usr/local/easysoft/oob/client \
  -D ODBC_LIBRARY=esoobclient \
```

For Empress:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=empress \
  -D ODBC_ROOT=/path/to/empress \
  -D ODBC_LIBRARY=empodbccl
```

For Empress Local Access:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=empress-bcs \
  -D ODBC_ROOT=/path/to/empress \
  -D ODBC_LIBRARY=empodbcbcs \
  -D ODBC_LINK_OPTIONS="-lempphpbcs -lms -lmscfg -lbasic -lbasic_os -lnlscstab -lnlsmsgtab -lm -ldl -lcrypt"
```

For IBM DB2:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=ibm-db2 \
  -D ODBC_ROOT=/home/db2inst1/sqllib \
  -D ODBC_LIBRARY=db2
```

For Solid DB:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_ODBC=ON \
  -D PHP_EXT_ODBC_TYPE=solid \
  -D ODBC_ROOT=/path/to/solid \
  -D ODBC_LIBRARY=sqlod \
  -D ODBC_INCLUDE_DIR=/path/to/solid/incl
```

> [!WARNING]
> These examples might need to be adjusted and updated for the current ODBC
> versions and implementations.

## PHP_EXT_ODBC_VERSION

:red_circle: *Removed as of PHP 8.5.*

Hex number to force support for the ODBC specification version. By default, it
is set to the highest supported ODBC specification version by PHP. A special
value `0` (zero) or empty value prevents an explicit `ODBCVER` to be defined in
the configuration header.

> [!NOTE]
> ODBC specification version overriding is not supported for `unixODBC` and
> `dbmaker` ODBC types.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionOdbc
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/Set)

option(PHP_EXT_ODBC "Enable the odbc extension")
add_feature_info(
  "ext/odbc"
  PHP_EXT_ODBC
  "Unified Open Database Connectivity (ODBC) databases support"
)

cmake_dependent_option(
  PHP_EXT_ODBC_SHARED
  "Build the odbc extension as a shared library"
  OFF
  PHP_EXT_ODBC
  OFF
)

php_set(
  PHP_EXT_ODBC_TYPE
  CHOICES
    "auto"
    "adabas"
    "dbmaker"
    "empress-bcs"
    "empress"
    "esoob"
    "ibm-db2"
    "iODBC"
    "sapdb"
    "solid"
    "unixODBC"
    "custom"
  IF PHP_EXT_ODBC
  DOC "The ODBC implementation type (library driving the ODBC)"
)
mark_as_advanced(PHP_EXT_ODBC_TYPE)

# Validate ODBC type for odbc and pdo_odbc extensions. Ideally, the same ODBC
# driver library should be used for both extensions.
if(
  PHP_EXT_ODBC
  AND PHP_EXT_PDO_ODBC
  AND NOT PHP_EXT_ODBC_TYPE STREQUAL PHP_EXT_PDO_ODBC_TYPE
)
  message(
    FATAL_ERROR
    "Different ODBC types detected for 'odbc' and 'pdo_odbc' PHP "
    "extensions:\n"
    "PHP_EXT_ODBC_TYPE=${PHP_EXT_ODBC_TYPE}\n"
    "PHP_EXT_PDO_ODBC_TYPE=${PHP_EXT_PDO_ODBC_TYPE}\n"
    "To prevent library symbol collisions when building both 'odbc' and "
    "'pdo_odbc' please link with the same ODBC library. Or disable one of "
    "the extensions by setting 'PHP_EXT_ODBC' or 'PHP_EXT_PDO_ODBC' to 'OFF'."
  )
endif()

# Some ODBC drivers require setting ODBC_LIBRARY manually to be found.
if(
  PHP_EXT_ODBC
  AND NOT PHP_EXT_ODBC_TYPE MATCHES "auto|unixODBC|iODBC"
  AND NOT ODBC_LIBRARY
)
  message(
    FATAL_ERROR
    "When using 'PHP_EXT_ODBC_TYPE=${PHP_EXT_ODBC_TYPE}', please set also "
    "'ODBC_LIBRARY' and optionally 'ODBC_INCLUDE_DIR' to locate the ODBC "
    "installation."
  )
endif()

if(NOT PHP_EXT_ODBC)
  return()
endif()

if(PHP_EXT_ODBC_SHARED)
  add_library(php_ext_odbc MODULE)
else()
  add_library(php_ext_odbc OBJECT)
endif()

target_sources(
  php_ext_odbc
  PRIVATE
    odbc_utils.c
    odbc.stub.php
    php_odbc.c
)

target_compile_definitions(php_ext_odbc PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(NOT PHP_EXT_ODBC_TYPE STREQUAL "auto")
  set(ODBC_USE_DRIVER "${PHP_EXT_ODBC_TYPE}")
endif()
find_package(ODBC)
set_package_properties(
  ODBC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the odbc extension."
)

target_link_libraries(php_ext_odbc PRIVATE ODBC::ODBC)

# Sanity checks.
if(PHP_EXT_ODBC_TYPE STREQUAL "ibm-db2" AND TARGET ODBC::ODBC)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ODBC::ODBC)
    check_include_files(sqlcli1.h PHP_EXT_ODBC_HAVE_SQLCLI1_H)
    set(HAVE_SQLCLI1_H ${PHP_EXT_ODBC_HAVE_SQLCLI1_H})
  cmake_pop_check_state()

  if(NOT PHP_EXT_ODBC_HAVE_SQLCLI1_H)
    message(FATAL_ERROR "Required <sqlcli1.h> header file not found.")
  endif()

  check_library_exists(ODBC::ODBC "" SQLExecute PHP_EXT_ODBC_HAS_SQLEXECUTE)

  if(NOT PHP_EXT_ODBC_HAS_SQLEXECUTE)
    message(
      FATAL_ERROR
      "ODBC build test failed. SQLExecute not found. The DB2 environment "
      "needs to be sourced. Run the command line:\n"
      "  . $IBM_DB2/db2profile"
    )
  endif()
endif()

################################################################################
# Configure config.h file.
################################################################################

# Set PHP_ODBC_TYPE for configuration header value.
if(ODBC_DRIVER STREQUAL "Windows")
  set(PHP_ODBC_TYPE "Win32")
elseif(
  (ODBC_DRIVER STREQUAL "iODBC" AND PHP_EXT_ODBC_TYPE STREQUAL "auto")
  OR PHP_EXT_ODBC_TYPE STREQUAL "iODBC"
)
  # To match the native build system string:
  set(PHP_ODBC_TYPE "iodbc")
elseif(ODBC_DRIVER AND PHP_EXT_ODBC_TYPE STREQUAL "auto")
  set(PHP_ODBC_TYPE "${ODBC_DRIVER}")
elseif(PHP_EXT_ODBC_TYPE STREQUAL "custom")
  # To match the native build system string:
  set(PHP_ODBC_TYPE custom-odbc)
else()
  set(PHP_ODBC_TYPE "${PHP_EXT_ODBC_TYPE}")
endif()

if(PHP_ODBC_TYPE STREQUAL "adabas")
  set(HAVE_ADABAS TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "dbmaker")
  set(HAVE_DBMAKER TRUE)
elseif(PHP_ODBC_TYPE MATCHES "^(empress|empress-bcs)$")
  set(HAVE_EMPRESS TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "esoob")
  set(HAVE_ESOOB TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "ibm-db2")
  set(HAVE_IBMDB2 TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "iodbc")
  set(HAVE_IODBC TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "sapdb")
  set(HAVE_SAPDB TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "solid")
  # Set based on the Solid version:
  if(ODBC_LIBRARY MATCHES [[23\.(a|so)$]])
    set(HAVE_SOLID TRUE)
  elseif(ODBC_LIBRARY MATCHES [[30\.(a|so)$]])
    set(HAVE_SOLID_30 TRUE)
  else()
    set(HAVE_SOLID_35 TRUE)
  endif()

  # Additional configuration for using obsolete <sqlunix.h> header on obsolete
  # systems.
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(SS_LINUX TRUE)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
    set(SS_FBX TRUE)
  endif()
elseif(PHP_ODBC_TYPE STREQUAL "unixODBC")
  set(HAVE_UNIXODBC TRUE)
elseif(PHP_ODBC_TYPE STREQUAL "custom-odbc")
  set(HAVE_CODBC TRUE)
endif()

if(NOT PHP_EXT_ODBC_TYPE MATCHES "^(dbmaker|solid)$")
  set(HAVE_SQLDATASOURCES TRUE)
endif()

if(TARGET ODBC::ODBC AND NOT ODBC_DRIVER STREQUAL "Windows")
  block(PROPAGATE PHP_ODBC_BUILD_DEFINITIONS_CODE)
    get_target_property(definitions ODBC::ODBC INTERFACE_COMPILE_DEFINITIONS)
    get_target_property(options ODBC::ODBC INTERFACE_COMPILE_OPTIONS)
    set(cflags "")
    if(definitions)
      list(APPEND cflags ${definitions})
    endif()
    if(options)
      list(APPEND cflags ${options})
    endif()
    if(cflags)
      list(JOIN cflags " " cflags)
    endif()

    get_target_property(libraries ODBC::ODBC IMPORTED_LOCATION)
    foreach(library ${libraries})
      cmake_path(GET library PARENT_PATH path)
      list(APPEND ldflags "-L${path}")

      cmake_path(GET library STEM name)
      string(REGEX REPLACE "^lib" "" name "${name}")
      list(APPEND libs "-l${name}")
    endforeach()

    get_target_property(options ODBC::ODBC INTERFACE_LINK_OPTIONS)
    if(options)
      list(APPEND ldflags ${options})
    endif()

    list(REMOVE_DUPLICATES ldflags)
    list(REMOVE_DUPLICATES libs)

    list(JOIN ldflags " " ldflags)
    list(JOIN libs " " libs)

    string(CONFIGURE [[
/* The compile options that PHP odbc extension was built with. */
#define PHP_ODBC_CFLAGS "@cflags@"

/* The linker flags that PHP odbc extension was built with. */
#define PHP_ODBC_LFLAGS "@ldflags@"

/* The libraries linker flags that PHP odbc extension was built with. */
#define PHP_ODBC_LIBS "@libs@"

/* The ODBC library used in the PHP odbc extension. */
#define PHP_ODBC_TYPE "@PHP_ODBC_TYPE@"]] PHP_ODBC_BUILD_DEFINITIONS_CODE)
  endblock()
endif()

set(HAVE_UODBC TRUE)

configure_file(cmake/config.h.in config.h)
