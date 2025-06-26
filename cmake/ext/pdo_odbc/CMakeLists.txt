#[=============================================================================[
# The pdo_odbc extension

Configure the `pdo_odbc` extension.

This extension provides PDO interface for using Unified Open Database
Connectivity (ODBC) databases.

## PHP_EXT_PDO_ODBC

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `pdo-odbc` extension.

## PHP_EXT_PDO_ODBC_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_PDO_ODBC_TYPE

* Default: `auto`
* Values: `auto`, `ibm-db2`, `iODBC`, `unixODBC`, or `custom`

Select the ODBC type.

When using `auto`, ODBC will be searched automatically and first found library
will be used.

When using `custom` or `ibm-db2`, also the `ODBC_LIBRARY` needs to be set
manually to find the ODBC library.

For example:

```sh
cmake -S . -B php-build \
  -D PHP_EXT_PDO_ODBC=ON \
  -D PHP_EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
```

For example, IBM DB2:

```sh
cmake -S php-src -B php-build \
  -D PHP_EXT_PDO_ODBC=ON \
  -D PHP_EXT_PDO_ODBC_TYPE=ibm-db2 \
  -D ODBC_ROOT=/home/db2inst1/sqllib \
  -D ODBC_LIBRARY=db2
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

For example:

```sh
cmake -S . -B php-build \
  -D PHP_EXT_PDO_ODBC=ON \
  -D PHP_EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so \
  -D ODBC_INCLUDE_DIR=/usr/include \
  -D ODBC_COMPILE_DEFINITIONS="-DSOME_DEF=1 -DSOME_OTHER_DEF_2=1" \
  -D ODBC_COMPILE_OPTIONS=... \
  -D ODBC_LINK_OPTIONS=...
```
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionPdoOdbc
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Set)

option(PHP_EXT_PDO_ODBC "Enable the pdo_odbc extension")
add_feature_info(
  "ext/pdo_odbc"
  PHP_EXT_PDO_ODBC
  "Unified Open Database Connectivity (ODBC) databases PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_ODBC_SHARED
  "Build the pdo_odbc extension as a shared library"
  OFF
  PHP_EXT_PDO_ODBC
  OFF
)

php_set(
  PHP_EXT_PDO_ODBC_TYPE
  CHOICES
    "auto"
    "ibm-db2"
    "iODBC"
    "unixODBC"
    "custom"
  IF PHP_EXT_PDO_ODBC
  DOC "The ODBC implementation type (library driving the ODBC)"
)
mark_as_advanced(PHP_EXT_PDO_ODBC_TYPE)

# Some ODBC drivers require setting ODBC_LIBRARY manually to be found.
if(
  PHP_EXT_PDO_ODBC
  AND NOT PHP_EXT_PDO_ODBC_TYPE MATCHES "auto|unixODBC|iODBC"
  AND NOT ODBC_LIBRARY
)
  message(
    FATAL_ERROR
    "When using 'PHP_EXT_PDO_ODBC_TYPE=${PHP_EXT_PDO_ODBC_TYPE}', please set "
    "also 'ODBC_LIBRARY' and optionally 'ODBC_INCLUDE_DIR' to find the ODBC "
    "installation."
  )
endif()

if(NOT PHP_EXT_PDO_ODBC)
  return()
endif()

if(PHP_EXT_PDO_ODBC_SHARED)
  add_library(php_ext_pdo_odbc MODULE)
else()
  add_library(php_ext_pdo_odbc OBJECT)
endif()

target_sources(
  php_ext_pdo_odbc
  PRIVATE
    odbc_driver.c
    odbc_stmt.c
    pdo_odbc.c
    pdo_odbc.stub.php
)

add_dependencies(php_ext_pdo_odbc php_ext_pdo)

if(NOT PHP_EXT_PDO_ODBC_TYPE STREQUAL "auto")
  set(ODBC_USE_DRIVER "${PHP_EXT_PDO_ODBC_TYPE}")
endif()
find_package(ODBC)
set_package_properties(
  ODBC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_odbc extension."
)

if(ODBC_DRIVER STREQUAL "Windows")
  set(PDO_ODBC_TYPE "Win32")
elseif(ODBC_DRIVER AND PHP_EXT_PDO_ODBC_TYPE STREQUAL "auto")
  set(PDO_ODBC_TYPE "${ODBC_DRIVER}")
elseif(PHP_EXT_PDO_ODBC_TYPE STREQUAL "custom")
  set(PDO_ODBC_TYPE "generic-${ODBC_LIBRARY}")
else()
  set(PDO_ODBC_TYPE "${PHP_EXT_PDO_ODBC_TYPE}")
endif()

if(TARGET ODBC::ODBC)
  block()
    set(haveSomeHeaders FALSE)

    foreach(
      header
      IN ITEMS
        cli0cli.h
        cli0core.h
        cli0defs.h
        cli0env.h
        cli0ext.h
        iodbc.h
        isql.h
        isqlext.h
        LibraryManager.h
        odbc.h
        sql.h
        sqlcli1.h
        sqlext.h
        sqltypes.h
        sqlucode.h
        sqlunix.h
        udbcext.h
    )
      string(MAKE_C_IDENTIFIER "HAVE_${header}" const)
      string(TOUPPER "${const}" const)

      message(CHECK_START "Looking for ${header}")
      if(EXISTS ${ODBC_INCLUDE_DIR}/${header})
        message(CHECK_PASS "found")
        set(haveSomeHeaders TRUE)
        set(${const} TRUE PARENT_SCOPE)
      else()
        message(CHECK_FAIL "not found")
      endif()
    endforeach()

    if(NOT haveSomeHeaders)
      message(
        FATAL_ERROR
        "Could not find any of the ODBC header files to build pdo_odbc "
        "extension."
      )
    endif()
  endblock()

  # Check for an ODBC 1.0 function to assert that the libraries work.
  check_library_exists(
    ODBC::ODBC
    SQLBindCol
    ""
    PHP_EXT_PDO_ODBC_HAS_SQLBINDCOL
  )

  if(NOT PHP_EXT_PDO_ODBC_HAS_SQLBINDCOL)
    message(
      FATAL_ERROR
      "Could not find the SQLBindCol ODBC 1.0 function in the ODBC library."
    )
  endif()

  # Check for an ODBC 3.0 function to assert that the libraries work.
  check_library_exists(
    ODBC::ODBC
    SQLAllocHandle
    ""
    PHP_EXT_PDO_ODBC_HAS_SQLALLOCHANDLE
  )

  if(NOT PHP_EXT_PDO_ODBC_HAS_SQLALLOCHANDLE)
    message(
      FATAL_ERROR
      "The ODBC library does not appear to be ODBC 3 compatible (the ODBC 3.0 "
      "function SQLAllocHandle not found). Consider using iODBC or unixODBC "
      "instead, and load libraries as a driver in that environment. It will "
      "emulate the functions required for PDO support."
    )
  endif()
endif()

target_link_libraries(php_ext_pdo_odbc PRIVATE ODBC::ODBC)

configure_file(cmake/config.h.in config.h)
