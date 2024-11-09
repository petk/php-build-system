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

# Some ODBC drivers require setting ODBC_LIBRARY manually to find package.
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

# TODO: Can this be fixed better?
get_target_property(extension_type php_pdo_odbc TYPE)
if(NOT extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
  target_link_libraries(php_pdo_odbc PRIVATE PHP::main)
endif()

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
if(ODBC_DRIVER AND EXT_PDO_ODBC_TYPE STREQUAL "auto")
  set(EXT_PDO_ODBC_TYPE "${ODBC_DRIVER}")
endif()

if(EXT_PDO_ODBC_TYPE STREQUAL "custom")
  set(PDO_ODBC_TYPE "generic-${ODBC_LIBRARY}")
else()
  set(PDO_ODBC_TYPE "${EXT_PDO_ODBC_TYPE}")
endif()

if(TARGET ODBC::ODBC)
  block()
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
        set(${const} 1)
        set(${const} 1 PARENT_SCOPE)
      else()
        message(CHECK_FAIL "not found")
      endif()

      if(${const})
        set(haveSomeHeaders TRUE)
      endif()
    endforeach()

    if(NOT haveSomeHeaders)
      message(FATAL_ERROR "Cannot find header file(s) for pdo_odbc")
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
      "function SQLAllocHandle not found. Consider using iODBC or unixODBC "
      "instead, and load libraries as a driver in that environment. It will "
      "emulate the functions required for PDO support."
    )
  endif()
endif()

target_link_libraries(php_pdo_odbc PRIVATE ODBC::ODBC)

configure_file(config.cmake.h.in config.h)
