#[=============================================================================[
# The ldap extension

This extension provides support for LDAP (Lightweight Directory Access
Protocol).

## Configuration options

### PHP_EXT_LDAP

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_LDAP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_LDAP_SASL

* Default: `OFF`
* Values: `ON|OFF`

Builds ldap extension with Cyrus SASL support.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_LDAP
  LANGUAGES C
)

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_LDAP "Enable the ldap extension")

add_feature_info(
  "ext/ldap"
  PHP_EXT_LDAP
  "LDAP (Lightweight Directory Access Protocol) support"
)

cmake_dependent_option(
  PHP_EXT_LDAP_SHARED
  "Build the ldap extension as a shared library"
  OFF
  PHP_EXT_LDAP
  OFF
)

cmake_dependent_option(
  PHP_EXT_LDAP_SASL
  "Build ldap extension with Cyrus SASL support"
  OFF
  PHP_EXT_LDAP
  OFF
)

if(NOT PHP_EXT_LDAP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(ldap)

if(PHP_EXT_LDAP_SHARED)
  add_library(php_ext_ldap MODULE)
else()
  add_library(php_ext_ldap OBJECT)
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
    check_symbol_exists(
      ldap_sasl_bind_s
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_SASL_BIND_S
    )
    if(NOT PHP_EXT_LDAP_HAVE_LDAP_SASL_BIND_S)
      # Fallback to deprecated ldap_simple_bind_s().
      check_symbol_exists(
        ldap_simple_bind_s
        ldap.h
        PHP_EXT_LDAP_HAVE_LDAP_SIMPLE_BIND_S
      )
    endif()
    if(
      NOT PHP_EXT_LDAP_HAVE_LDAP_SASL_BIND_S
      AND NOT PHP_EXT_LDAP_HAVE_LDAP_SIMPLE_BIND_S
    )
      message(
        FATAL_ERROR
        "LDAP sanity check failed: neither 'ldap_sasl_bind_s()' nor "
        "'ldap_simple_bind_s()' function could be found."
      )
    endif()

    message(CHECK_START "Checking for 3 arg ldap_set_rebind_proc")
    check_source_compiles(C [[
      #include <ldap.h>

      int main(void)
      {
        ldap_set_rebind_proc(0, 0, 0);
        return 0;
      }
    ]] PHP_EXT_LDAP_HAVE_3ARG_SETREBINDPROC)
    if(PHP_EXT_LDAP_HAVE_3ARG_SETREBINDPROC)
      message(CHECK_PASS "yes")
    else()
      message(CHECK_PASS "no")
    endif()
    set(HAVE_3ARG_SETREBINDPROC ${PHP_EXT_LDAP_HAVE_3ARG_SETREBINDPROC})

    # Solaris 2.8 claims to be 2004 API, but doesn't have ldap_parse_reference()
    # nor ldap_start_tls_s().
    check_symbol_exists(
      ldap_control_find
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_CONTROL_FIND
    )
    set(HAVE_LDAP_CONTROL_FIND ${PHP_EXT_LDAP_HAVE_LDAP_CONTROL_FIND})

    check_symbol_exists(
      ldap_extended_operation
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_EXTENDED_OPERATION
    )
    set(
      HAVE_LDAP_EXTENDED_OPERATION
      ${PHP_EXT_LDAP_HAVE_LDAP_EXTENDED_OPERATION}
    )

    check_symbol_exists(
      ldap_extended_operation_s
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_EXTENDED_OPERATION_S
    )
    set(
      HAVE_LDAP_EXTENDED_OPERATION_S
      ${PHP_EXT_LDAP_HAVE_LDAP_EXTENDED_OPERATION_S}
    )

    check_symbol_exists(
      ldap_parse_extended_result
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_PARSE_EXTENDED_RESULT
    )
    set(
      HAVE_LDAP_PARSE_EXTENDED_RESULT
      ${PHP_EXT_LDAP_HAVE_LDAP_PARSE_EXTENDED_RESULT}
    )

    check_symbol_exists(
      ldap_parse_reference
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_PARSE_REFERENCE
    )
    set(HAVE_LDAP_PARSE_REFERENCE ${PHP_EXT_LDAP_HAVE_LDAP_PARSE_REFERENCE})

    check_symbol_exists(
      ldap_parse_result
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_PARSE_RESULT
    )
    set(HAVE_LDAP_PARSE_RESULT ${PHP_EXT_LDAP_HAVE_LDAP_PARSE_RESULT})

    check_symbol_exists(
      ldap_passwd
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_PASSWD
    )
    set(HAVE_LDAP_PASSWD ${PHP_EXT_LDAP_HAVE_LDAP_PASSWD})

    check_symbol_exists(
      ldap_refresh_s
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_REFRESH_S
    )
    set(HAVE_LDAP_REFRESH_S ${PHP_EXT_LDAP_HAVE_LDAP_REFRESH_S})

    check_symbol_exists(
      ldap_start_tls_s
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_START_TLS_S
    )
    set(HAVE_LDAP_START_TLS_S ${PHP_EXT_LDAP_HAVE_LDAP_START_TLS_S})

    check_symbol_exists(
      ldap_whoami_s
      ldap.h
      PHP_EXT_LDAP_HAVE_LDAP_WHOAMI_S
    )
    set(HAVE_LDAP_WHOAMI_S ${PHP_EXT_LDAP_HAVE_LDAP_WHOAMI_S})
  cmake_pop_check_state()
endif()

if(PHP_EXT_LDAP_SASL)
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
