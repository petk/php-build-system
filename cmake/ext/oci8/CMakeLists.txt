#[=============================================================================[
# The oci8 extension

Configure the `oci8` extension.

## EXT_OCI8

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_GMP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_OCI8_11G

* Default: `OFF`
* Values: `ON|OFF`

Enable OCI8 support using Oracle 11g Instant Client.

## EXT_OCI8_12C

* Default: `OFF`
* Values: `ON|OFF`

Enable OCI8 support using Oracle Database 12c Instant Client.

## EXT_OCI8_19

* Default: `OFF`
* Values: `ON|OFF`

Enable OCI8 support using Oracle Database 19 Instant Client.
#]=============================================================================]

project(
  PhpExtensionOci8
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_OCI8 "Enable the oci8 extension")

add_feature_info(
  "ext/oci8"
  EXT_OCI8
  "Oracle database support"
)

cmake_dependent_option(
  EXT_OCI8_SHARED
  "Build the oci8 extension as a shared library"
  OFF
  "EXT_OCI8;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_OCI8_11G
  "Enable OCI8 support using Oracle 11g Instant Client"
  OFF
  "EXT_OCI8"
  OFF
)

cmake_dependent_option(
  EXT_OCI8_12C
  "Enable OCI8 support using Oracle Database 12c Instant Client"
  OFF
  "EXT_OCI8"
  OFF
)

cmake_dependent_option(
  EXT_OCI8_19
  "Enable OCI8 support using Oracle Database 19 Instant Client"
  OFF
  "EXT_OCI8"
  OFF
)

if(NOT EXT_OCI8)
  return()
endif()

if(EXT_OCI8_SHARED)
  add_library(php_oci8 SHARED)
else()
  add_library(php_oci8)
endif()

target_sources(
  php_oci8
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
  cmake_language(DEFER DIRECTORY ${dir} CALL php_oci8_notice)
endif()
function(php_oci8_notice)
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
