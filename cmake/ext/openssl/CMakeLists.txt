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
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Use system default cipher list instead of hardcoded value for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_SYSTEM_CIPHERS)

add_feature_info(
  "ext/openssl system ciphers"
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Using system default cipher list instead of hardcoded value for OpenSSL"
)

cmake_dependent_option(
  EXT_OPENSSL_ARGON2
  "Enable OpenSSL Argon2 password hashing (requires OpenSSL >= 3.2)"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_ARGON2)

add_feature_info(
  "ext/openssl Argon2"
  EXT_OPENSSL_ARGON2
  "Password hashing"
)

cmake_dependent_option(
  EXT_OPENSSL_LEGACY_PROVIDER
  "OpenSSL >= 3: Load legacy algorithm provider in addition to default provider"
  OFF
  "EXT_OPENSSL"
  OFF
)
mark_as_advanced(EXT_OPENSSL_LEGACY_PROVIDER)

add_feature_info(
  "ext/openssl legacy algorithm provider"
  EXT_OPENSSL_LEGACY_PROVIDER
  "Legacy algorithm provider in addition to default provider will be loaded"
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
    openssl_pwhash.c
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

# Link publicly for internal_functions files.
target_link_libraries(php_openssl PUBLIC OpenSSL::SSL OpenSSL::Crypto)

set(
  HAVE_OPENSSL_EXT 1
  CACHE INTERNAL "Whether the openssl extension is available."
)

if(TARGET OpenSSL::SSL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
    check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)
  cmake_pop_check_state()

  if(OPENSSL_VERSION VERSION_LESS 3 AND EXT_OPENSSL_LEGACY_PROVIDER)
    message(
      WARNING
      "EXT_OPENSSL_LEGACY_PROVIDER is not available for OpenSSL version "
      "${OPENSSL_VERSION} and won't be enabled."
    )
  elseif(
    OPENSSL_VERSION VERSION_GREATER_EQUAL 3
    AND EXT_OPENSSL_LEGACY_PROVIDER
  )
    set(
      LOAD_OPENSSL_LEGACY_PROVIDER 1
      CACHE INTERNAL
      "Load legacy algorithm provider in addition to default provider"
    )
  endif()

  if(EXT_OPENSSL_SYSTEM_CIPHERS)
    set(
      USE_OPENSSL_SYSTEM_CIPHERS 1
      CACHE INTERNAL "Whether to use system default cipher list instead of hardcoded value"
    )
  endif()

  if(EXT_OPENSSL_ARGON2)
    if(PHP_THREAD_SAFETY)
      message(
        FATAL_ERROR
        "The OpenSSL Argon2 password hashing is not supported in thread-safe "
        "mode for now. Please, disable thread safety (set 'PHP_THREAD_SAFETY' "
        "to 'OFF'), or build without OpenSSL Argon2 (set 'EXT_OPENSSL_ARGON2' "
        "to 'OFF')."
      )
    endif()

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
      check_symbol_exists(
        OSSL_set_max_threads
        "openssl/thread.h"
        HAVE_OPENSSL_ARGON2
      )
    cmake_pop_check_state()

    if(OPENSSL_VERSION VERSION_LESS 3.2 OR NOT HAVE_OPENSSL_ARGON2)
      message(
        FATAL_ERROR
        "The OpenSSL Argon2 password hashing requires OpenSSL 3.2 or newer."
      )
    endif()
  endif()
endif()
