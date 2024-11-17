#[=============================================================================[
# The ftp extension

Configure the `ftp` extension.

## EXT_FTP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_FTP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_FTP_SSL

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable FTP over SSL support when building without openssl extension
(`EXT_OPENSSL=OFF`) or when using `phpize`. If the `openssl` extension is
enabled at the configure step (`EXT_OPENSSL=ON`), FTP-SSL is enabled implicitly
regardless of this option.
#]=============================================================================]

project(
  PhpExtensionFtp
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_FTP "Enable the ftp extension" OFF)

add_feature_info(
  "ext/ftp"
  EXT_FTP
  "File Transfer Protocol (FTP) support"
)

cmake_dependent_option(
  EXT_FTP_SHARED
  "Build the ftp extension as a shared library"
  OFF
  "EXT_FTP;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_FTP_SSL
  "Explicitly enable FTP over SSL support when building without openssl\
  extension (EXT_OPENSSL=OFF) or when using phpize."
  OFF
  "EXT_FTP;NOT EXT_OPENSSL"
  OFF
)

if(NOT EXT_FTP)
  return()
endif()

if(EXT_FTP_SHARED)
  add_library(php_ftp SHARED)
else()
  add_library(php_ftp)
endif()

target_sources(
  php_ftp
  PRIVATE
    ftp.c
    ftp.stub.php
    php_ftp.c
)

if(EXT_FTP_SSL OR EXT_OPENSSL)
  find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
  set_package_properties(
    OpenSSL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the ftp extension."
  )

  target_link_libraries(php_ftp PRIVATE OpenSSL::SSL)

  set(HAVE_FTP_SSL 1)
endif()

add_feature_info(
  "ext/ftp SSL"
  HAVE_FTP_SSL
  "FTP over SSL support"
)

set(HAVE_FTP 1)

configure_file(config.cmake.h.in config.h)
