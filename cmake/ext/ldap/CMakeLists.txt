#[=============================================================================[
# The ldap extension

Configure the `ldap` extension.

This extension provides support for LDAP (Lightweight Directory Access
Protocol).

## EXT_LDAP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_LDAP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_LDAP_SASL

* Default: `OFF`
* Values: `ON|OFF`

Build ldap extension with Cyrus SASL support.
#]=============================================================================]

project(
  PhpExtensionLdap
  LANGUAGES C
)

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_LDAP "Enable the ldap extension")

add_feature_info(
  "ext/ldap"
  EXT_LDAP
  "LDAP (Lightweight Directory Access Protocol) support"
)

cmake_dependent_option(
  EXT_LDAP_SHARED
  "Build the ldap extension as a shared library"
  OFF
  "EXT_LDAP;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_LDAP_SASL
  "Build ldap extension with Cyrus SASL support"
  OFF
  "EXT_LDAP"
  OFF
)

if(NOT EXT_LDAP)
  return()
endif()

if(EXT_LDAP_SHARED)
  add_library(php_ext_ldap SHARED)
else()
  add_library(php_ext_ldap)
endif()

target_sources(
  php_ext_ldap
  PRIVATE
    ldap.c
    ldap.stub.php
)

target_compile_definitions(php_ext_ldap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(LDAP)
set_package_properties(
  LDAP
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the ldap extension."
)

target_link_libraries(php_ext_ldap PRIVATE LDAP::LDAP)

if(TARGET LDAP::LDAP)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES LDAP::LDAP)

    # Sanity check.
    check_symbol_exists(ldap_sasl_bind_s "ldap.h" _HAVE_LDAP_SASL_BIND_S)
    # Fallback to deprecated ldap_simple_bind_s().
    if(NOT _HAVE_LDAP_SASL_BIND_S)
      check_symbol_exists(ldap_simple_bind_s "ldap.h" _HAVE_LDAP_SIMPLE_BIND_S)
    endif()
    if(NOT _HAVE_LDAP_SASL_BIND_S AND NOT _HAVE_LDAP_SIMPLE_BIND_S)
      message(
        FATAL_ERROR
        "LDAP sanity check failed: ldap_sasl_bind_s() or ldap_simple_bind_s() "
        "not found. "
      )
    endif()

    message(CHECK_START "Checking for 3 arg ldap_set_rebind_proc")
    check_source_compiles(C [[
      #include <ldap.h>

      int main(void)
      {
        ldap_set_rebind_proc(0,0,0);
        return 0;
      }
    ]] HAVE_3ARG_SETREBINDPROC)
    if(HAVE_3ARG_SETREBINDPROC)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_PASS "no")
    endif()

    # Solaris 2.8 claims to be 2004 API, but doesn't have ldap_parse_reference()
    # nor ldap_start_tls_s().
    check_symbol_exists(ldap_parse_result "ldap.h" HAVE_LDAP_PARSE_RESULT)
    check_symbol_exists(ldap_parse_reference "ldap.h" HAVE_LDAP_PARSE_REFERENCE)
    check_symbol_exists(ldap_start_tls_s "ldap.h" HAVE_LDAP_START_TLS_S)
    check_symbol_exists(ldap_control_find "ldap.h" HAVE_LDAP_CONTROL_FIND)
    check_symbol_exists(ldap_parse_extended_result "ldap.h" HAVE_LDAP_PARSE_EXTENDED_RESULT)
    check_symbol_exists(ldap_extended_operation "ldap.h" HAVE_LDAP_EXTENDED_OPERATION)
    check_symbol_exists(ldap_extended_operation_s "ldap.h" HAVE_LDAP_EXTENDED_OPERATION_S)
    check_symbol_exists(ldap_passwd "ldap.h" HAVE_LDAP_PASSWD)
    check_symbol_exists(ldap_whoami_s "ldap.h" HAVE_LDAP_WHOAMI_S)
    check_symbol_exists(ldap_refresh_s "ldap.h" HAVE_LDAP_REFRESH_S)
  cmake_pop_check_state()
endif()

if(EXT_LDAP_SASL)
  find_package(SASL)
  set_package_properties(
    SASL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the Cyrus SASL support in the ldap extension."
  )

  target_link_libraries(php_ext_ldap PRIVATE SASL::SASL)

  set(HAVE_LDAP_SASL TRUE)
endif()

set(HAVE_LDAP TRUE)

configure_file(cmake/config.h.in config.h)
