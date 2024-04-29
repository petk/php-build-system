include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_OPENSSL "Enable the openssl extension" OFF)

add_feature_info(
  "ext/openssl"
  EXT_OPENSSL
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
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Use system default cipher list instead of hardcoded value for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_KERBEROS)

cmake_dependent_option(
  EXT_OPENSSL_LEGACY_PROVIDER
  "OpenSSL >= 3: Load legacy algorithm provider in addition to default provider"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_SYSTEM_CIPHERS)

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

find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
set_package_properties(
  OpenSSL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the openssl extension."
)

# Link publicly to transitively pass OpenSSL::SSL target items to possible other
# extensions (for example, ext/phar), when the ext/openssl is enabled.
target_link_libraries(php_openssl PUBLIC OpenSSL::SSL OpenSSL::Crypto)

set(
  HAVE_OPENSSL_EXT 1
  CACHE INTERNAL "Whether the openssl extension is available"
)

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

if(OPENSSL_VERSION VERSION_GREATER_EQUAL 3 AND EXT_OPENSSL_LEGACY_PROVIDER)
  set(
    LOAD_OPENSSL_LEGACY_PROVIDER 1
    CACHE INTERNAL
    "Load legacy algorithm provider in addition to default provider"
  )
endif()
