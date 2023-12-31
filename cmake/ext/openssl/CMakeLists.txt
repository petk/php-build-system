# The ext/openssl variables are needed by some other extensions.
set_directory_properties(PROPERTIES PHP_PRIORITY 1)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_OPENSSL "Enable the openssl extension" OFF)

add_feature_info("ext/openssl" EXT_OPENSSL
  "OpenSSL library support for encryption and decryption."
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

add_feature_info("ext/openssl Kerberos" EXT_OPENSSL_KERBEROS "\
When using OpenSSL library built with Kerberos enabled. Deprecated. Kerberos \
support has been removed as of OpenSSL 1.1.0.\
")

cmake_dependent_option(
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Use system default cipher list instead of hardcoded value for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)

if(NOT EXT_OPENSSL)
  return()
endif()

if(EXT_OPENSSL_SHARED)
  add_library(php_openssl SHARED)
else()
  add_library(php_openssl)
endif()

target_sources(php_openssl PRIVATE
  openssl.c
  xp_ssl.c
)

if(EXT_OPENSSL_KERBEROS)
  message(
    DEPRECATION
    "Support for Kerberos in the openssl extension is deprecated. Kerberos has "
    "been removed as of OpenSSL 1.1.0 upstream library."
  )

  find_package(Kerberos)
  set_package_properties(Kerberos PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to use Kerberos support in the openssl extension."
  )

  target_link_libraries(php_openssl PRIVATE Kerberos::Kerberos)
endif()

find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
set_package_properties(OpenSSL PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the openssl extension."
)

target_link_libraries(php_openssl PRIVATE OpenSSL::SSL)
target_link_libraries(php_openssl PRIVATE OpenSSL::Crypto)

set(HAVE_OPENSSL_EXT 1 CACHE INTERNAL "Whether the OpenSSL extension is available")

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
