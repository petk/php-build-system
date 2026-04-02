#[=============================================================================[
# The pdo_oci extension

This extension provides PDO interface for using Oracle database.

## Configuration options

### PHP_EXT_PDO_OCI

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PDO_OCI
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_PDO_OCI "Enable the pdo_oci extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/pdo_oci"
  PHP_EXT_PDO_OCI
  "Oracle database PDO driver"
)

if(NOT PHP_EXT_PDO_OCI)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo_oci)

if(PHP_EXT_PDO_OCI STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_pdo_oci MODULE)
else()
  add_library(php_ext_pdo_oci OBJECT)
endif()

target_sources(
  php_ext_pdo_oci
  PRIVATE
    oci_driver.c
    oci_statement.c
    pdo_oci.c
)

set_property(
  TARGET php_ext_pdo_oci
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pdo
)

target_include_directories(
  php_ext_pdo_oci
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

configure_file(cmake/config.h.in config.h)
