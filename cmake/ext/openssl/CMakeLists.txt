include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_OPENSSL "Enable the openssl extension" OFF)

add_feature_info(
  "ext/openssl"
  EXT_OPENSSL
  "OpenSSL library support for encryption and decryption"
)

cmake_dependent_option(
  EXT_OPENSSL_SHARED
  "Build the openssl extension as a shared library"
  OFF
  "EXT_OPENSSL;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_OPENSSL_KERBEROS
  "Include Kerberos support for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_KERBEROS)

add_feature_info(
  "ext/openssl Kerberos"
  EXT_OPENSSL_KERBEROS
  "Using OpenSSL library built with Kerberos enabled. Deprecated. Kerberos\
  support has been removed as of OpenSSL 1.1.0."
)

cmake_dependent_option(
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Use system default cipher list instead of hardcoded value for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_SYSTEM_CIPHERS)

# There is a platform symbol definition inconsistency that is being addressed:
# https://github.com/php/php-src/pull/14333. The HAVE_OPENSS_EXT on Windows is
# defined to 0/1 value based on the openssl extension built as shared or
# statically, elsewhere it is defined to value 1.
set(
  HAVE_OPENSSL_EXT "/* #undef HAVE_OPENSSL_EXT */"
  CACHE INTERNAL "Whether the openssl extension is available"
)

if(NOT EXT_OPENSSL)
  return()
endif()

if(EXT_OPENSSL_SHARED)
  add_library(php_openssl SHARED)
else()
  add_library(php_openssl)
endif()

target_sources(
  php_openssl
  PRIVATE
    openssl.c
    xp_ssl.c
)

if(EXT_OPENSSL_KERBEROS)
  message(
    DEPRECATION
    "Support for Kerberos in the openssl extension is deprecated. Kerberos has "
    "been removed as of OpenSSL 1.1.0 upstream library."
  )

  find_package(Kerberos COMPONENTS Krb5 GSSAPI)
  set_package_properties(
    Kerberos
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use Kerberos support in the openssl extension."
  )

  target_link_libraries(php_openssl PRIVATE Kerberos::Krb5 Kerberos::GSSAPI)
endif()

find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
set_package_properties(
  OpenSSL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the openssl extension."
)

# Link publicly for internal_functions files.
target_link_libraries(php_openssl PUBLIC OpenSSL::SSL OpenSSL::Crypto)

block()
  set_property(
    CACHE HAVE_OPENSSL_EXT
    PROPERTY VALUE "#define HAVE_OPENSSL_EXT 1"
  )

  get_target_property(type php_openssl TYPE)
  if(
    CMAKE_SYSTEM_NAME STREQUAL "Windows" AND
    type MATCHES "^(MODULE|SHARED)_LIBRARY$"
  )
    set_property(
      CACHE HAVE_OPENSSL_EXT
      PROPERTY VALUE "#define HAVE_OPENSSL_EXT 0"
    )
  endif()
endblock()

if(TARGET OpenSSL::SSL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
    check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)
  cmake_pop_check_state()
endif()

if(EXT_OPENSSL_SYSTEM_CIPHERS)
  set(
    USE_OPENSSL_SYSTEM_CIPHERS 1
    CACHE INTERNAL "Use system default cipher list instead of hardcoded value"
  )
endif()
