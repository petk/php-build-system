#[=============================================================================[
# The ftp extension

This extension provides support for File Transfer Protocol (FTP).

## Configuration options

### PHP_EXT_FTP

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_FTP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_FTP_SSL

* Default: `ON`
* Values: `ON|OFF`

Explicitly enables or disables FTP over SSL support.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_FTP
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_FTP "Enable the ftp extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/ftp"
  PHP_EXT_FTP
  "File Transfer Protocol (FTP) support"
)

cmake_dependent_option(
  PHP_EXT_FTP_SHARED
  "Build the ftp extension as a shared library"
  ${PROJECT_IS_TOP_LEVEL}
  PHP_EXT_FTP
  OFF
)

cmake_dependent_option(
  PHP_EXT_FTP_SSL
  "Explicitly enable FTP over SSL support."
  ON
  PHP_EXT_FTP
  OFF
)

if(NOT PHP_EXT_FTP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(ftp)

if(PHP_EXT_FTP_SHARED)
  add_library(php_ext_ftp MODULE)
else()
  add_library(php_ext_ftp OBJECT)
endif()

target_sources(
  php_ext_ftp
  PRIVATE
    ftp.c
    ftp.stub.php
    php_ftp.c
)

target_include_directories(php_ext_ftp PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

if(PHP_EXT_FTP_SSL)
  include(PHP/Package/OpenSSL)
  find_package(OpenSSL ${PHP_PACKAGE_OPENSSL_MIN_VERSION} COMPONENTS SSL)
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
