#[=============================================================================[
# The pdo_odbc extension

Configure the `pdo_odbc` extension.

## EXT_PDO_ODBC

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `pdo-odbc` extension.

## EXT_PDO_ODBC_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## EXT_PDO_ODBC_TYPE

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
  -D EXT_PDO_ODBC=ON \
  -D EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so
```

For example, IBM DB2:

```sh
cmake -S php-src -B php-build \
  -D EXT_PDO_ODBC=ON \
  -D EXT_PDO_ODBC_TYPE=ibm-db2 \
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
  -D EXT_PDO_ODBC=ON \
  -D EXT_PDO_ODBC_TYPE=custom \
  -D ODBC_LIBRARY=/usr/lib/x86_64-linux-gnu/libodbc.so \
  -D ODBC_INCLUDE_DIR=/usr/include \
  -D ODBC_COMPILE_DEFINITIONS="-DSOME_DEF=1 -DSOME_OTHER_DEF_2=1" \
  -D ODBC_COMPILE_OPTIONS=... \
  -D ODBC_LINK_OPTIONS=...
```
#]=============================================================================]

project(
  PhpExtensionPdoOdbc
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Set)

option(EXT_PDO_ODBC "Enable the pdo_odbc extension" OFF)
add_feature_info(
  "ext/pdo_odbc"
  EXT_PDO_ODBC
  "Unified Open Database Connectivity (ODBC) databases support in PDO"
)

cmake_dependent_option(
  EXT_PDO_ODBC_SHARED
  "Build the pdo_odbc extension as a shared library"
  OFF
  [[EXT_PDO_ODBC AND NOT BUILD_SHARED_LIBS]]
  OFF
)

php_set(
  EXT_PDO_ODBC_TYPE
  CHOICES
    "auto"
    "ibm-db2"
    "iODBC"
    "unixODBC"
    "custom"
  IF EXT_PDO_ODBC
  DOC "The ODBC implementation type (library driving the ODBC)"
)
mark_as_advanced(EXT_PDO_ODBC_TYPE)

# Some ODBC drivers require setting ODBC_LIBRARY manually to be found.
if(
  EXT_PDO_ODBC
  AND NOT EXT_PDO_ODBC_TYPE MATCHES "auto|unixODBC|iODBC"
  AND NOT ODBC_LIBRARY
)
  message(
    FATAL_ERROR
    "When using EXT_PDO_ODBC_TYPE=${EXT_PDO_ODBC_TYPE}, please set also "
    "ODBC_LIBRARY and optionally ODBC_INCLUDE_DIR to find the ODBC "
    "installation."
  )
endif()

if(NOT EXT_PDO_ODBC)
  return()
endif()

if(EXT_PDO_ODBC_SHARED)
  add_library(php_pdo_odbc SHARED)
else()
  add_library(php_pdo_odbc)
endif()

target_sources(
  php_pdo_odbc
  PRIVATE
    odbc_driver.c
    odbc_stmt.c
    pdo_odbc.c
    pdo_odbc.stub.php
)

add_dependencies(php_pdo_odbc php_pdo)

target_include_directories(
  php_pdo_odbc
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

if(NOT EXT_PDO_ODBC_TYPE STREQUAL "auto")
  set(ODBC_USE_DRIVER "${EXT_PDO_ODBC_TYPE}")
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
elseif(ODBC_DRIVER AND EXT_PDO_ODBC_TYPE STREQUAL "auto")
  set(PDO_ODBC_TYPE "${ODBC_DRIVER}")
elseif(EXT_PDO_ODBC_TYPE STREQUAL "custom")
  set(PDO_ODBC_TYPE "generic-${ODBC_LIBRARY}")
else()
  set(PDO_ODBC_TYPE "${EXT_PDO_ODBC_TYPE}")
endif()

if(TARGET ODBC::ODBC)
  block()
    set(haveSomeHeaders)

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
        set(${const} 1 PARENT_SCOPE)
      else()
        message(CHECK_FAIL "not found")
      endif()
    endforeach()

    if(NOT haveSomeHeaders)
      message(
        FATAL_ERROR
        "Could not found any of the ODBC header files to build pdo_odbc extension"
      )
    endif()
  endblock()

  # Check for an ODBC 1.0 function to assert that the libraries work.
  check_library_exists(ODBC::ODBC SQLBindCol "" _HAVE_SQLBINDCOL)

  if(NOT _HAVE_SQLBINDCOL)
    message(
      FATAL_ERROR
      "Could not find the SQLBindCol ODBC 1.0 function in the ODBC library."
    )
  endif()

  # Check for an ODBC 3.0 function to assert that the libraries work.
  check_library_exists(ODBC::ODBC SQLAllocHandle "" _HAVE_SQLALLOCHANDLE)

  if(NOT _HAVE_SQLALLOCHANDLE)
    message(
      FATAL_ERROR
      "The ODBC library does not appear to be ODBC 3 compatible (the ODBC 3.0 "
      "function SQLAllocHandle not found). Consider using iODBC or unixODBC "
      "instead, and load libraries as a driver in that environment. It will "
      "emulate the functions required for PDO support."
    )
  endif()
endif()

target_link_libraries(php_pdo_odbc PRIVATE ODBC::ODBC)

configure_file(config.cmake.h.in config.h)
