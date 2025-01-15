#[=============================================================================[
# The oci8 extension

Configure the `oci8` extension.

## PHP_EXT_OCI8

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_GMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_OCI8_11G

* Default: `OFF`
* Values: `ON|OFF`

Enable OCI8 support using Oracle 11g Instant Client.

## PHP_EXT_OCI8_12C

* Default: `OFF`
* Values: `ON|OFF`

Enable OCI8 support using Oracle Database 12c Instant Client.

## PHP_EXT_OCI8_19

* Default: `OFF`
* Values: `ON|OFF`

Enable OCI8 support using Oracle Database 19 Instant Client.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionOci8
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_OCI8 "Enable the oci8 extension")

add_feature_info(
  "ext/oci8"
  PHP_EXT_OCI8
  "Oracle database support"
)

cmake_dependent_option(
  PHP_EXT_OCI8_SHARED
  "Build the oci8 extension as a shared library"
  OFF
  "PHP_EXT_OCI8;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  PHP_EXT_OCI8_11G
  "Enable OCI8 support using Oracle 11g Instant Client"
  OFF
  "PHP_EXT_OCI8"
  OFF
)

cmake_dependent_option(
  PHP_EXT_OCI8_12C
  "Enable OCI8 support using Oracle Database 12c Instant Client"
  OFF
  "PHP_EXT_OCI8"
  OFF
)

cmake_dependent_option(
  PHP_EXT_OCI8_19
  "Enable OCI8 support using Oracle Database 19 Instant Client"
  OFF
  "PHP_EXT_OCI8"
  OFF
)

if(NOT PHP_EXT_OCI8)
  return()
endif()

if(PHP_EXT_OCI8_SHARED)
  add_library(php_ext_oci8 SHARED)
else()
  add_library(php_ext_oci8)
endif()

target_sources(
  php_ext_oci8
  PRIVATE
    oci8_collection.c
    oci8_failover.c
    oci8_interface.c
    oci8_lob.c
    oci8_statement.c
    oci8.c
    oci8.stub.php
)

set(PHP_OCI8_INSTANT_CLIENT "")

# Run at the end of the configuration: Warn about Apache if oci8 extension is
# enabled on Linux without PHP_SIGCHILD.
if(NOT PHP_OCI8_INSTANT_CLIENT AND NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  if(PHP_SOURCE_DIR)
    set(dir ${PHP_SOURCE_DIR})
  else()
    set(dir ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  cmake_language(DEFER DIRECTORY ${dir} CALL php_ext_oci8_notice)
endif()
function(php_ext_oci8_notice)
  cmake_language(DEFER CALL message NOTICE [[

    The oci8 extension notice:

    If you encounter <defunc> processes when using a local Oracle
    database, set the value 'BEQUEATH_DETACH=YES' in Oracle Net's
    'sqlnet.ora' file on the PHP host, or set the environment variable
    'BEQUEATH_DETACH' to 'YES' before starting Apache. If the problem
    still occurs, then recompile PHP and specify 'PHP_SIGCHILD'
    configuration variable.
  ]])
endfunction()

set(HAVE_OCI8 TRUE)

configure_file(cmake/config.h.in config.h)
