#[=============================================================================[
# The libxml extension

Configure the `libxml` extension.

This extension provides XML parser and toolkit support using libxml2 library.

## PHP_EXT_LIBXML

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

This extension cannot be built as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionLibXml
  LANGUAGES C
)

include(FeatureSummary)

option(
  PHP_EXT_LIBXML
  "Enable the libxml extension (can be built only statically)"
  ON
)

add_feature_info(
  "ext/libxml"
  PHP_EXT_LIBXML
  "XML parser and toolkit support using libxml2 library"
)

if(NOT PHP_EXT_LIBXML)
  return()
endif()

add_library(php_ext_libxml OBJECT)

target_sources(
  php_ext_libxml
  PRIVATE
    libxml.c
    libxml.stub.php
    mime_sniff.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_libxml.h
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND TARGET php_sapi)
  target_sources(php_sapi INTERFACE php_libxml2.def)
endif()

target_compile_definitions(
  php_ext_libxml
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Windows>:LIBXML_STATIC;LIBXML_STATIC_FOR_DLL>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the libxml extension."
)

# HAVE_WIN32_THREADS is not needed on newer libxml2 versions anymore.
if(LIBXML2_VERSION_STRING VERSION_LESS 2.10)
  target_compile_definitions(
    php_ext_libxml
    PRIVATE
      $<$<PLATFORM_ID:Windows>:HAVE_WIN32_THREADS>
  )
endif()

target_link_libraries(php_ext_libxml PUBLIC LibXml2::LibXml2)

set(HAVE_LIBXML TRUE)

configure_file(cmake/config.h.in config.h)
