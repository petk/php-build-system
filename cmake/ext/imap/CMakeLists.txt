#[=============================================================================[
# The imap extension

Configure the `imap` extension.

This extension provides support for operating with the IMAP protocol.

## PHP_EXT_IMAP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_IMAP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_IMAP_KERBEROS

* Default: `OFF`
* Values: `ON|OFF`

Explicitly include Kerberos support in the imap extension.

## PHP_EXT_IMAP_SSL

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable SSL support in the imap extension. If c-client dependency is
built with SSL support, this option will be automatically enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionImap
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_IMAP "Enable the imap extension")

add_feature_info(
  "ext/imap"
  PHP_EXT_IMAP
  "IMAP protocol support"
)

cmake_dependent_option(
  PHP_EXT_IMAP_SHARED
  "Build the imap extension as a shared library"
  OFF
  "PHP_EXT_IMAP;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  PHP_EXT_IMAP_KERBEROS
  "Explicitly include Kerberos support in the imap extension."
  OFF
  "PHP_EXT_IMAP"
  OFF
)

cmake_dependent_option(
  PHP_EXT_IMAP_SSL
  "Explicitly enable SSL support in the imap extension"
  OFF
  "PHP_EXT_IMAP"
  OFF
)

if(NOT PHP_EXT_IMAP)
  return()
endif()

if(PHP_EXT_IMAP_SHARED)
  add_library(php_ext_imap MODULE)
else()
  add_library(php_ext_imap)
endif()

target_sources(
  php_ext_imap
  PRIVATE
    php_imap.c
    php_imap.stub.php
)

target_compile_definitions(php_ext_imap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(Cclient)
set_package_properties(
  Cclient
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the imap extension."
)

target_link_libraries(
  php_ext_imap
  PRIVATE
    $<$<PLATFORM_ID:Windows>:ws2_32;secur32;crypt32;winmm>
  # Link publicly for internal_functions files.
  PUBLIC
    Cclient::Cclient
)

if(TARGET Cclient::Cclient)
  block()
    message(CHECK_START "Checking for Kerberos support in imap extension")

    file(
      STRINGS
      ${Cclient_INCLUDE_DIR}/linkage.h
      auth_gss_results
      REGEX
      [[auth_gss;$]]
    )

    if(
      (NOT PHP_EXT_IMAP_KERBEROS AND auth_gss_results)
      OR PHP_EXT_IMAP_KERBEROS
    )
      find_package(Kerberos COMPONENTS Krb5 GSSAPI)
      set_package_properties(
        Kerberos
        PROPERTIES
          TYPE REQUIRED
          PURPOSE "Necessary for Kerberos support in the imap extension."
      )

      target_link_libraries(php_ext_imap PRIVATE Kerberos::Krb5 Kerberos::GSSAPI)

      if(Kerberos_FOUND)
        set(HAVE_IMAP_KRB TRUE)
        message(CHECK_PASS "yes")
      else()
        message(CHECK_FAIL "failed")

        if(auth_gss_results)
          message(
            WARNING
            "The imap extension requires Kerberos because c-client library is "
            "built with Kerberos support."
          )
        endif()
      endif()
    else()
      message(CHECK_FAIL "no")
    endif()
  endblock()

  block()
    message(CHECK_START "Checking for SSL support in imap extension")

    file(
      STRINGS
      ${Cclient_INCLUDE_DIR}/linkage.c
      ssl_onceonlyinit_results
      REGEX
      "ssl_onceonlyinit[ \t]*\\(\\);$"
    )

    if((NOT PHP_EXT_IMAP_SSL AND ssl_onceonlyinit_results) OR PHP_EXT_IMAP_SSL)
      find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION} COMPONENTS SSL)
      set_package_properties(
        OpenSSL
        PROPERTIES
          TYPE REQUIRED
          PURPOSE "Necessary to enable SSL in the imap extension."
      )

      target_link_libraries(php_ext_imap PRIVATE OpenSSL::SSL)

      if(OpenSSL_FOUND)
        set(HAVE_IMAP_SSL TRUE)
        message(CHECK_PASS "yes")
      else()
        message(CHECK_FAIL "failed")

        if(ssl_onceonlyinit_results)
          message(
            WARNING
            "The imap extension requires SSL because c-client library is built "
            "with SSL support."
          )
        endif()
      endif()
    else()
      message(CHECK_FAIL "no")
    endif()
  endblock()
endif()

set(HAVE_IMAP TRUE)

configure_file(cmake/config.h.in config.h)
