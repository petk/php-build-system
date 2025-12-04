#[=============================================================================[
# The pdo_oci extension

Configure the `pdo_oci` extension.

This extension provides PDO interface for using Oracle database.

## PHP_EXT_PDO_OCI

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PDO_OCI_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_PDO_OCI
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_PDO_OCI "Enable the pdo_oci extension")

add_feature_info(
  "ext/pdo_oci"
  PHP_EXT_PDO_OCI
  "Oracle database PDO driver"
)

cmake_dependent_option(
  PHP_EXT_PDO_OCI_SHARED
  "Build the pdo_oci extension as a shared library"
  OFF
  PHP_EXT_PDO_OCI
  OFF
)

if(NOT PHP_EXT_PDO_OCI)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(pdo_oci)

if(PHP_EXT_PDO_OCI_SHARED)
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

add_dependencies(php_ext_pdo_oci php_ext_pdo)

target_include_directories(
  php_ext_pdo_oci
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

configure_file(cmake/config.h.in config.h)
