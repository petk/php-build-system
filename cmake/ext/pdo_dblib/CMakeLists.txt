#[=============================================================================[
# The pdo_dblib extension

This extension provides PDO interface for using Microsoft SQL Server and Sybase
databases.

## Configuration options

### PHP_EXT_PDO_DBLIB

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PDO_DBLIB
  LANGUAGES C
)

include(FeatureSummary)

option(
  PHP_EXT_PDO_DBLIB
  "Enable the pdo_dblib extension"
  ${PROJECT_IS_TOP_LEVEL}
)

add_feature_info(
  "ext/pdo_dblib"
  PHP_EXT_PDO_DBLIB
  "Microsoft SQL Server and Sybase database PDO driver"
)

if(NOT PHP_EXT_PDO_DBLIB)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo_dblib)

if(PHP_EXT_PDO_DBLIB STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_pdo_dblib MODULE)
else()
  add_library(php_ext_pdo_dblib OBJECT)
endif()

target_sources(
  php_ext_pdo_dblib
  PRIVATE
    dblib_driver.c
    dblib_stmt.c
    pdo_dblib.c
)

set_property(
  TARGET php_ext_pdo_dblib
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pdo
)

target_compile_definitions(
  php_ext_pdo_dblib
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    PDO_DBLIB_FLAVOUR="freetds"
)

target_include_directories(
  php_ext_pdo_dblib
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

find_package(FreeTDS)
set_package_properties(
  FreeTDS
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_dblib extension."
)

target_link_libraries(php_ext_pdo_dblib PRIVATE FreeTDS::FreeTDS)

set(HAVE_PDO_DBLIB TRUE)

configure_file(cmake/config.h.in config.h)
