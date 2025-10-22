#[=============================================================================[
# The openssl extension

Configure the `openssl` extension.

This extension enables encryption and decryption support using the OpenSSL
library.

## PHP_EXT_OPENSSL

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `openssl` extension.

Where to find OpenSSL installation on the system, can be customized with the
`OPENSSL_ROOT_DIR` variable.

## PHP_EXT_OPENSSL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_OPENSSL_SYSTEM_CIPHERS

* Default: `OFF`
* Values: `ON|OFF`

Use system default cipher list instead of the hardcoded value for OpenSSL.

## PHP_EXT_OPENSSL_ARGON2

:green_circle: *New in PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Enable OpenSSL Argon2 password hashing. Requires OpenSSL >= 3.2.

## PHP_EXT_OPENSSL_LEGACY_PROVIDER

:green_circle: *New in PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Load OpenSSL legacy algorithm provider in addition to the default provider.
Requires OpenSSL >= 3. Legacy algorithms are by OpenSSL library considered those
that are either insecure, or have fallen out of use.

## PHP_EXT_OPENSSL_KERBEROS

:red_circle: *Removed as of PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Include Kerberos support for OpenSSL.

Where to find Kerberos installation on the system, can be customized with the
`KERBEROS_ROOT` variable.

Note, that Kerberos support has been removed from the OpenSSL library as of
OpenSSL 1.1.0.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_OPENSSL
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_OPENSSL "Enable the openssl extension")

add_feature_info(
  "ext/openssl"
  PHP_EXT_OPENSSL
  "encryption and decryption using OpenSSL library"
)

cmake_dependent_option(
  PHP_EXT_OPENSSL_SHARED
  "Build the openssl extension as a shared library"
  OFF
  PHP_EXT_OPENSSL
  OFF
)

cmake_dependent_option(
  PHP_EXT_OPENSSL_SYSTEM_CIPHERS
  "Use system default cipher list instead of hardcoded value for OpenSSL"
  OFF
  PHP_EXT_OPENSSL
  OFF
)
mark_as_advanced(PHP_EXT_OPENSSL_SYSTEM_CIPHERS)

add_feature_info(
  "ext/openssl system ciphers"
  PHP_EXT_OPENSSL_SYSTEM_CIPHERS
  "system default cipher list instead of hardcoded value"
)

cmake_dependent_option(
  PHP_EXT_OPENSSL_ARGON2
  "Enable OpenSSL Argon2 password hashing (requires OpenSSL >= 3.2)"
  OFF
  PHP_EXT_OPENSSL
  OFF
)
mark_as_advanced(PHP_EXT_OPENSSL_ARGON2)

add_feature_info(
  "ext/openssl Argon2"
  PHP_EXT_OPENSSL_ARGON2
  "password hashing"
)

cmake_dependent_option(
  PHP_EXT_OPENSSL_LEGACY_PROVIDER
  "OpenSSL >= 3: Load legacy algorithm provider in addition to default provider"
  OFF
  PHP_EXT_OPENSSL
  OFF
)
mark_as_advanced(PHP_EXT_OPENSSL_LEGACY_PROVIDER)

add_feature_info(
  "ext/openssl legacy algorithm provider"
  PHP_EXT_OPENSSL_LEGACY_PROVIDER
  "loaded in addition to default provider"
)

if(NOT PHP_EXT_OPENSSL)
  return()
endif()

if(PHP_EXT_OPENSSL_SHARED)
  add_library(php_ext_openssl MODULE)
else()
  add_library(php_ext_openssl OBJECT)
endif()

target_sources(
  php_ext_openssl
  PRIVATE
    openssl_pwhash.c
    openssl_pwhash.stub.php
    openssl.c
    openssl.stub.php
    xp_ssl.c
)

find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION} COMPONENTS SSL)
set_package_properties(
  OpenSSL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the openssl extension."
)

# Link publicly for internal_functions files.
target_link_libraries(php_ext_openssl PUBLIC OpenSSL::SSL)

if(TARGET OpenSSL::SSL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
    check_symbol_exists(RAND_egd openssl/rand.h PHP_EXT_OPENSSL_HAVE_RAND_EGD)
    set(HAVE_RAND_EGD ${PHP_EXT_OPENSSL_HAVE_RAND_EGD})
  cmake_pop_check_state()

  if(OpenSSL_VERSION VERSION_LESS 3 AND PHP_EXT_OPENSSL_LEGACY_PROVIDER)
    message(
      WARNING
      "PHP_EXT_OPENSSL_LEGACY_PROVIDER is not available for OpenSSL version "
      "${OpenSSL_VERSION} and won't be enabled."
    )
  elseif(
    OpenSSL_VERSION VERSION_GREATER_EQUAL 3
    AND PHP_EXT_OPENSSL_LEGACY_PROVIDER
  )
    set(LOAD_OPENSSL_LEGACY_PROVIDER TRUE)
  endif()

  if(PHP_EXT_OPENSSL_SYSTEM_CIPHERS)
    set(USE_OPENSSL_SYSTEM_CIPHERS TRUE)
  endif()

  if(PHP_EXT_OPENSSL_ARGON2)
    if(PHP_THREAD_SAFETY)
      message(
        FATAL_ERROR
        "The OpenSSL Argon2 password hashing is not supported in thread-safe "
        "mode for now. Please, disable thread safety (set 'PHP_THREAD_SAFETY' "
        "to 'OFF'), or build without OpenSSL Argon2 (set "
        "'PHP_EXT_OPENSSL_ARGON2' to 'OFF')."
      )
    endif()

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
      check_symbol_exists(
        OSSL_set_max_threads
        openssl/thread.h
        PHP_EXT_OPENSSL_HAVE_OPENSSL_ARGON2
      )
      set(HAVE_OPENSSL_ARGON2 ${PHP_EXT_OPENSSL_HAVE_OPENSSL_ARGON2})
    cmake_pop_check_state()

    if(
      OpenSSL_VERSION VERSION_LESS 3.2
      OR NOT PHP_EXT_OPENSSL_HAVE_OPENSSL_ARGON2
    )
      message(
        FATAL_ERROR
        "The OpenSSL Argon2 password hashing requires OpenSSL 3.2 or newer."
      )
    endif()
  endif()
endif()

set(HAVE_OPENSSL_EXT TRUE)

configure_file(cmake/config.h.in config.h)
