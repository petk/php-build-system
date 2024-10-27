project(
  PhpExtensionOci8
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_OCI8 "Enable the oci8 extension" OFF)

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

# Warn about Apache if oci8 extension is enabled on Linux without PHP_SIGCHILD.
function(_php_oci8_notice)
  if(
    PHP_SIGCHILD
    OR PHP_OCI8_INSTANT_CLIENT
    OR CMAKE_SYSTEM_NAME STREQUAL "Windows"
  )
    return()
  endif()

  message(NOTICE "
+--------------------------------------------------------------------+
| The oci8 extension notice:                                         |
| If you encounter <defunc> processes when using a local Oracle      |
| database, set the value BEQUEATH_DETACH=YES in Oracle Net's        |
| sqlnet.ora file on the PHP host, or set the environment variable   |
| BEQUEATH_DETACH to YES before starting Apache.  If the problem     |
| still occurs, then recompile PHP and specify --enable-sigchild     |
| when configuring.                                                  |
+--------------------------------------------------------------------+
")
endfunction()

# Run at the end of the configuration.
cmake_language(
  DEFER
    DIRECTORY ${PHP_SOURCE_DIR}
  CALL _php_oci8_notice
)

set(HAVE_OCI8 1)

configure_file(config.cmake.h.in config.h @ONLY)
