#[=============================================================================[
# The pdo_dblib extension

Configure the `pdo_dblib` extension.

This extension provides PDO interface for using Microsoft SQL Server and Sybase
databases.

## PHP_EXT_PDO_DBLIB

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PDO_DBLIB_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionPdoDblib
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_PDO_DBLIB "Enable the pdo_dblib extension")

add_feature_info(
  "ext/pdo_dblib"
  PHP_EXT_PDO_DBLIB
  "Microsoft SQL Server and Sybase database PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_DBLIB_SHARED
  "Build the pdo_dblib extension as a shared library"
  OFF
  "PHP_EXT_PDO_DBLIB;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PDO_DBLIB)
  return()
endif()

if(PHP_EXT_PDO_DBLIB_SHARED)
  add_library(php_ext_pdo_dblib SHARED)
else()
  add_library(php_ext_pdo_dblib)
endif()

target_sources(
  php_ext_pdo_dblib
  PRIVATE
    dblib_driver.c
    dblib_stmt.c
    pdo_dblib.c
    pdo_dblib.stub.php
)

add_dependencies(php_ext_pdo_dblib php_ext_pdo)

target_compile_definitions(
  php_ext_pdo_dblib
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    PDO_DBLIB_FLAVOUR="freetds"
)

find_package(FreeTDS)
set_package_properties(
  FreeTDS
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pdo_dblib extension."
)

target_link_libraries(php_ext_pdo_dblib PRIVATE FreeTDS::FreeTDS)
