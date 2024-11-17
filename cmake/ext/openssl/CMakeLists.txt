#[=============================================================================[
# The openssl extension

Configure the `openssl` extension.

This extension enables using OpenSSL library for encryption and decryption.

## EXT_OPENSSL

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `openssl` extension.

Where to find OpenSSL installation on the system, can be customized with the
`OPENSSL_ROOT_DIR` variable.

## EXT_OPENSSL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## EXT_OPENSSL_SYSTEM_CIPHERS

* Default: `OFF`
* Values: `ON|OFF`

Use system default cipher list instead of the hardcoded value for OpenSSL.

## EXT_OPENSSL_KERBEROS

:orange_circle: *Deprecated as of PHP 8.3.*

* Default: `OFF`
* Values: `ON|OFF`

Include Kerberos support for OpenSSL.

Where to find Kerberos installation on the system, can be customized with the
`Kerberos_ROOT` variable.

Note, that Kerberos support has been removed as of OpenSSL 1.1.0, which makes
this option deprecated.
#]=============================================================================]

project(
  PhpExtensionOpenSsl
  LANGUAGES C
)

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

add_feature_info(
  "ext/openssl system ciphers"
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Using system default cipher list instead of hardcoded value for OpenSSL"
)

set(HAVE_OPENSSL_EXT "/* #undef HAVE_OPENSSL_EXT */")

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
    openssl.stub.php
    xp_ssl.c
)

if(EXT_OPENSSL_KERBEROS)
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

block(PROPAGATE HAVE_OPENSSL_EXT_CODE)
  get_target_property(type php_openssl TYPE)
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
    check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)
  cmake_pop_check_state()

  if(EXT_OPENSSL_SYSTEM_CIPHERS)
    set(USE_OPENSSL_SYSTEM_CIPHERS 1)
  endif()
endif()

set(HAVE_OPENSSL 1)

configure_file(config.cmake.h.in config.h)
