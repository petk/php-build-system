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

## PHP_EXT_OPENSSL_KERBEROS

:orange_circle: *Deprecated as of PHP 8.3.*

* Default: `OFF`
* Values: `ON|OFF`

Include Kerberos support for OpenSSL.

Where to find Kerberos installation on the system, can be customized with the
`KERBEROS_ROOT` variable.

Note, that Kerberos support has been removed as of OpenSSL 1.1.0, which makes
this option deprecated.
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
  PHP_EXT_OPENSSL_KERBEROS
  "Include Kerberos support for OpenSSL. Deprecated. Kerberos support has been\
  removed as of OpenSSL 1.1.0."
  OFF
  PHP_EXT_OPENSSL
  OFF
)
mark_as_advanced(PHP_EXT_OPENSSL_KERBEROS)

add_feature_info(
  "ext/openssl Kerberos"
  PHP_EXT_OPENSSL_KERBEROS
  "OpenSSL library built with Kerberos"
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

if(NOT PHP_EXT_OPENSSL)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(openssl)

if(PHP_EXT_OPENSSL_SHARED)
  add_library(php_ext_openssl MODULE)
else()
  add_library(php_ext_openssl OBJECT)
endif()

target_sources(
  php_ext_openssl
  PRIVATE
    openssl.c
    openssl.stub.php
    xp_ssl.c
)

if(PHP_EXT_OPENSSL_KERBEROS)
  message(
    DEPRECATION
    "Support for Kerberos in the PHP openssl extension is deprecated. Kerberos "
    "has been removed as of OpenSSL 1.1.0 upstream library."
  )

  find_package(Kerberos COMPONENTS Krb5 GSSAPI)
  set_package_properties(
    Kerberos
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use Kerberos support in the openssl extension."
  )

  target_link_libraries(php_ext_openssl PRIVATE Kerberos::Krb5 Kerberos::GSSAPI)
endif()

find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION} COMPONENTS SSL)
set_package_properties(
  OpenSSL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the openssl extension."
)

# Link publicly for internal_functions files.
target_link_libraries(php_ext_openssl PUBLIC OpenSSL::SSL)

block(PROPAGATE HAVE_OPENSSL_EXT_CODE)
  get_target_property(type php_ext_openssl TYPE)
  if(
    CMAKE_SYSTEM_NAME STREQUAL "Windows" AND
    type MATCHES "^(MODULE|SHARED)_LIBRARY$"
  )
    set(HAVE_OPENSSL_EXT_CODE "#define HAVE_OPENSSL_EXT 0")
  else()
    set(HAVE_OPENSSL_EXT_CODE "#define HAVE_OPENSSL_EXT 1")
  endif()
endblock()

if(TARGET OpenSSL::SSL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
    check_symbol_exists(RAND_egd openssl/rand.h PHP_EXT_OPENSSL_HAVE_RAND_EGD)
    set(HAVE_RAND_EGD ${PHP_EXT_OPENSSL_HAVE_RAND_EGD})
  cmake_pop_check_state()

  if(PHP_EXT_OPENSSL_SYSTEM_CIPHERS)
    set(USE_OPENSSL_SYSTEM_CIPHERS TRUE)
  endif()
endif()

set(HAVE_OPENSSL TRUE)

configure_file(cmake/config.h.in config.h)
