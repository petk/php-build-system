# TODO: Recheck other LDAP implementations supported by ext/ldap.

include(CheckCSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_LDAP "Enable the ldap extension" OFF)

add_feature_info("ext/ldap" EXT_LDAP
  "Adds support for LDAP (Lightweight Directory Access Protocol)."
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
  add_library(php_ldap SHARED)
else()
  add_library(php_ldap)
endif()

target_sources(php_ldap PRIVATE
  ldap.c
)

target_compile_definitions(php_ldap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(LDAP)
set_package_properties(LDAP PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the ldap extension."
)

target_link_libraries(php_ldap PRIVATE LDAP::LDAP)

message(STATUS "Checking for 3 arg ldap_set_rebind_proc")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES LDAP::LDAP)

  check_c_source_compiles("
    #include <ldap.h>

    int main(void) {
      ldap_set_rebind_proc(0,0,0);
      return 0;
    }
  " HAVE_3ARG_SETREBINDPROC)

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

if(EXT_LDAP_SASL)
  find_package(SASL)
  set_package_properties(SASL PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the Cyrus SASL support in the ldap extension."
  )

  target_link_libraries(php_ldap PRIVATE SASL::SASL)

  set(HAVE_LDAP_SASL 1 CACHE INTERNAL "Whether LDAP has SASL support")
endif()

# Sanity check.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES LDAP::LDAP)

  check_symbol_exists(ldap_sasl_bind_s "ldap.h" _have_ldap_sasl_bind_s)
cmake_pop_check_state()

if(NOT _have_ldap_sasl_bind_s)
  message(FATAL_ERROR "LDAP build check failed. Please check logs for more information.")
endif()

unset(_have_ldap_sasl_bind_s CACHE)
