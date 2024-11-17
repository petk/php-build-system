#[=============================================================================[
# The pdo_oci extension

Configure the `pdo_oci` extension.

This extension provides PDO interface for using Oracle database.

## EXT_PDO_OCI

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_PDO_OCI_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPdoOci
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PDO_OCI "Enable the pdo_oci extension" OFF)

add_feature_info(
  "ext/pdo_oci"
  EXT_PDO_OCI
  "Oracle database support in PDO (PHP Data Objects) interface"
)

cmake_dependent_option(
  EXT_PDO_OCI_SHARED
  "Build the pdo_oci extension as a shared library"
  OFF
  "EXT_PDO_OCI;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PDO_OCI)
  return()
endif()

if(EXT_PDO_OCI_SHARED)
  add_library(php_pdo_oci SHARED)
else()
  add_library(php_pdo_oci)
endif()

target_sources(
  php_pdo_oci
  PRIVATE
    oci_driver.c
    oci_statement.c
    pdo_oci.c
)

add_dependencies(php_pdo_oci php_pdo)

target_include_directories(
  php_pdo_oci
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

configure_file(config.cmake.h.in config.h)
