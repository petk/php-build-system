#[=============================================================================[
# The ftp extension

Configure the `ftp` extension.

This extension provides support for File Transfer Protocol (FTP).

## PHP_EXT_FTP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_FTP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_FTP_SSL

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable FTP over SSL support when building without openssl extension
(`PHP_EXT_OPENSSL=OFF`) or when using `phpize`. If the `openssl` extension is
enabled at the configure step (`PHP_EXT_OPENSSL=ON`), FTP-SSL is enabled
implicitly regardless of this option.
#]=============================================================================]

project(
  PhpExtensionFtp
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_FTP "Enable the ftp extension")

add_feature_info(
  "ext/ftp"
  PHP_EXT_FTP
  "File Transfer Protocol (FTP) support"
)

cmake_dependent_option(
  PHP_EXT_FTP_SHARED
  "Build the ftp extension as a shared library"
  OFF
  "PHP_EXT_FTP;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  PHP_EXT_FTP_SSL
  "Explicitly enable FTP over SSL support when building without openssl\
  extension (PHP_EXT_OPENSSL=OFF) or when using phpize."
  OFF
  "PHP_EXT_FTP;NOT PHP_EXT_OPENSSL"
  OFF
)

if(NOT PHP_EXT_FTP)
  return()
endif()

if(PHP_EXT_FTP_SHARED)
  add_library(php_ext_ftp SHARED)
else()
  add_library(php_ext_ftp)
endif()

target_sources(
  php_ext_ftp
  PRIVATE
    ftp.c
    ftp.stub.php
    php_ftp.c
)

if(PHP_EXT_FTP_SSL OR PHP_EXT_OPENSSL)
  find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
  set_package_properties(
    OpenSSL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the ftp extension."
  )

  target_link_libraries(php_ext_ftp PRIVATE OpenSSL::SSL)

  set(HAVE_FTP_SSL TRUE)
endif()

add_feature_info(
  "ext/ftp SSL"
  HAVE_FTP_SSL
  "FTP over SSL"
)

set(HAVE_FTP TRUE)

configure_file(cmake/config.h.in config.h)
