#[=============================================================================[
# The pdo extension

Configure the `pdo` extension.

This extension provides support for PHP Data Objects (PDO).

## PHP_EXT_PDO

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PDO_SHARED

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

option(PHP_EXT_PDO "Enable the pdo extension" ON)

add_feature_info(
  "ext/pdo"
  PHP_EXT_PDO
  "PHP Data Objects (PDO)"
)

cmake_dependent_option(
  PHP_EXT_PDO_SHARED
  "Build the pdo extension as a shared library"
  OFF
  "PHP_EXT_PDO;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PDO)
  return()
endif()

if(PHP_EXT_PDO_SHARED)
  add_library(php_ext_pdo SHARED)
else()
  add_library(php_ext_pdo)
endif()

target_sources(
  php_ext_pdo
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
        php_pdo.h
        php_pdo_driver.h
        php_pdo_error.h
)

add_dependencies(php_ext_pdo php_ext_spl)

if(RE2C_FOUND)
  re2c_target(
    php_ext_pdo_sql_parser
    pdo_sql_parser.re
    ${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c
    CODEGEN
  )
endif()
