#[=============================================================================[
# The zip extension

Configure the `zip` extension.

This extension provides support for reading and writing ZIP compressed archives.

## EXT_ZIP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_ZIP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionZip
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ZIP "Enable the zip extension")

add_feature_info(
  "ext/zip"
  EXT_ZIP
  "ZIP (.zip) compressed archives support"
)

cmake_dependent_option(
  EXT_ZIP_SHARED
  "Build the zip extension as a shared library"
  OFF
  "EXT_ZIP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ZIP)
  return()
endif()

if(EXT_ZIP_SHARED)
  add_library(php_zip SHARED)
else()
  add_library(php_zip)
endif()

target_sources(
  php_zip
  PRIVATE
    php_zip.c
    php_zip.stub.php
    zip_stream.c
)

add_dependencies(php_zip php_pcre)

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
    "ext/zip: libzip ${libzip_VERSION} is not supported. Try upgrading libzip"
  )
endif()

target_link_libraries(php_zip PRIVATE libzip::libzip)

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
  check_library_exists(
    libzip::libzip
    zip_file_set_mtime
    ""
    HAVE_SET_MTIME
  )

  if(NOT HAVE_SET_MTIME)
    message(WARNING "Libzip >= 1.0.0 needed for setting mtime")
  endif()

  check_library_exists(
    libzip::libzip
    zip_file_set_encryption
    ""
    HAVE_ENCRYPTION
  )

  if(NOT HAVE_ENCRYPTION)
    message(WARNING "Libzip >= 1.2.0 needed for encryption support")
  endif()

  check_library_exists(
    libzip::libzip
    zip_libzip_version
    ""
    HAVE_LIBZIP_VERSION
  )

  check_library_exists(
    libzip::libzip
    zip_register_progress_callback_with_state
    ""
    HAVE_PROGRESS_CALLBACK
  )

  check_library_exists(
    libzip::libzip
    zip_register_cancel_callback_with_state
    ""
    HAVE_CANCEL_CALLBACK
  )

  check_library_exists(
    libzip::libzip
    zip_compression_method_supported
    ""
    HAVE_METHOD_SUPPORTED
  )
endif()

set(HAVE_ZIP TRUE)

configure_file(cmake/config.h.in config.h)
