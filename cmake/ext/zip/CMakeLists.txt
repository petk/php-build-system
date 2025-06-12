#[=============================================================================[
# The zip extension

Configure the `zip` extension.

This extension provides support for reading and writing ZIP compressed archives.

## PHP_EXT_ZIP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_ZIP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionZip
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
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
  "PHP_EXT_ZIP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_ZIP)
  return()
endif()

if(PHP_EXT_ZIP_SHARED)
  add_library(php_ext_zip SHARED)
else()
  add_library(php_ext_zip)
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
  find_package(libzip 0.11...1.3.0)
endif()

if(libzip_VERSION VERSION_EQUAL 1.3.1 OR libzip_VERSION VERSION_EQUAL 1.7.0)
  message(
    FATAL_ERROR
    "ext/zip: libzip ${libzip_VERSION} is not supported. Try upgrading libzip."
  )
endif()

target_link_libraries(php_ext_zip PRIVATE libzip::libzip)

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

if(TARGET libzip::libzip)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES libzip::libzip)

    check_symbol_exists(zip_file_set_mtime zip.h HAVE_SET_MTIME)

    if(NOT HAVE_SET_MTIME)
      message(
        WARNING
        "ext/zip will not have support for setting mtime "
        "(Libzip >= 1.0.0 is needed for setting mtime)"
      )
    endif()

    check_symbol_exists(zip_file_set_encryption zip.h HAVE_ENCRYPTION)

    if(NOT HAVE_ENCRYPTION)
      message(
        WARNING
        "ext/zip will not have encryption support "
        "(Libzip >= 1.2.0 is needed for encryption support)"
      )
    endif()

    check_symbol_exists(
      zip_libzip_version
      zip.h
      HAVE_LIBZIP_VERSION
    )

    check_symbol_exists(
      zip_register_progress_callback_with_state
      zip.h
      HAVE_PROGRESS_CALLBACK
    )

    check_symbol_exists(
      zip_register_cancel_callback_with_state
      zip.h
      HAVE_CANCEL_CALLBACK
    )

    check_symbol_exists(
      zip_compression_method_supported
      zip.h
      HAVE_METHOD_SUPPORTED
    )
  cmake_pop_check_state()
endif()

set(HAVE_ZIP TRUE)

configure_file(cmake/config.h.in config.h)
