#[=============================================================================[
# The zip extension

This extension provides support for reading and writing ZIP compressed archives.

## Configuration options

### PHP_EXT_ZIP

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_ZIP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_ZIP
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_ZIP "Enable the zip extension")

add_feature_info(
  "ext/zip"
  PHP_EXT_ZIP
  "ZIP (.zip) compressed archives support"
)

cmake_dependent_option(
  PHP_EXT_ZIP_SHARED
  "Build the zip extension as a shared library"
  OFF
  PHP_EXT_ZIP
  OFF
)

if(NOT PHP_EXT_ZIP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(zip)

if(PHP_EXT_ZIP_SHARED)
  add_library(php_ext_zip MODULE)
else()
  add_library(php_ext_zip OBJECT)
endif()

target_sources(
  php_ext_zip
  PRIVATE
    php_zip.c
    php_zip.stub.php
    zip_stream.c
)

add_dependencies(php_ext_zip php_ext_pcre)

find_package(libzip 1.7.1)
set_package_properties(
  libzip
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the zip extension."
)

if(NOT libzip_FOUND)
  find_package(libzip 1.3.2...1.6.999)
endif()

if(NOT libzip_FOUND)
  find_package(libzip 0.11.2...1.3.0)
endif()

if(libzip_VERSION VERSION_EQUAL 1.3.1 OR libzip_VERSION VERSION_EQUAL 1.7.0)
  message(
    FATAL_ERROR
    "ext/zip: libzip ${libzip_VERSION} is not supported. Try upgrading libzip."
  )
endif()

# Link publicly for internal_functions files.
target_link_libraries(php_ext_zip PUBLIC libzip::zip)

# Note: ZIP_STATIC needs to be defined when using static libzip on Windows only
# since version 1.0 to 1.3.2
if(
  CMAKE_SYSTEM_NAME STREQUAL "Windows"
  AND libzip_VERSION VERSION_GREATER_EQUAL 1.0
  AND libzip_VERSION VERSION_LESS 1.4.0
)
  # TODO: Adjust this if the libzip is a static library.
  if(TODO)
    set(ZIP_STATIC TRUE)
    #set(LZMA_API_STATIC TRUE)
  endif()
endif()

# TODO: When downloading and building libzip from source additional deps are
# required.

if(libzip_FOUND)
  if(libzip_VERSION VERSION_GREATER_EQUAL 1.0.0)
    set(HAVE_SET_MTIME TRUE)
  else()
    message(
      WARNING
      "ext/zip will not have support for setting mtime "
      "(Libzip >= 1.0.0 is needed for setting mtime)"
    )
  endif()

  if(libzip_VERSION VERSION_GREATER_EQUAL 1.2.0)
    set(HAVE_ENCRYPTION TRUE)
  else()
    message(
      WARNING
      "ext/zip will not have encryption support "
      "(Libzip >= 1.2.0 is needed for encryption support)"
    )
  endif()

  if(libzip_VERSION VERSION_GREATER_EQUAL 1.3.0)
    set(HAVE_PROGRESS_CALLBACK TRUE)
  endif()

  if(libzip_VERSION VERSION_GREATER_EQUAL 1.3.1)
    set(HAVE_LIBZIP_VERSION TRUE)
  endif()

  if(libzip_VERSION VERSION_GREATER_EQUAL 1.6.0)
    set(HAVE_CANCEL_CALLBACK TRUE)
  endif()

  if(libzip_VERSION VERSION_GREATER_EQUAL 1.7.0)
    set(HAVE_METHOD_SUPPORTED TRUE)
  endif()
endif()

set(HAVE_ZIP TRUE)

configure_file(cmake/config.h.in config.h)
