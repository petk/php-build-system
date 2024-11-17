#[=============================================================================[
# The pdo extension

Configure the `pdo` extension.

This extension provides support for PHP Data Objects (PDO).

## EXT_PDO

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_PDO_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPdo
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO "Enable the pdo extension" ON)

add_feature_info(
  "ext/pdo"
  EXT_PDO
  "PHP Data Objects (PDO) support"
)

cmake_dependent_option(
  EXT_PDO_SHARED
  "Build the pdo extension as a shared library"
  OFF
  "EXT_PDO;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO)
  return()
endif()

if(EXT_PDO_SHARED)
  add_library(php_pdo SHARED)
else()
  add_library(php_pdo)
endif()

target_sources(
  php_pdo
  PRIVATE
    pdo_dbh.c
    pdo_dbh.stub.php
    pdo_sql_parser.c
    pdo_sqlstate.c
    pdo_stmt.c
    pdo_stmt.stub.php
    pdo.c
    pdo.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        pdo_sql_parser.h
        php_pdo_driver.h
        php_pdo_error.h
        php_pdo.h
)

add_dependencies(php_pdo php_spl)

if(RE2C_FOUND)
  re2c_target(
    php_pdo_sql_parser
    pdo_sql_parser.re
    ${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c
  )
endif()
