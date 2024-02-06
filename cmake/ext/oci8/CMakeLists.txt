include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_OCI8 "Enable the oci8 extension" OFF)

add_feature_info(
  "ext/oci8"
  EXT_OCI8
  "Oracle database support."
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
)
