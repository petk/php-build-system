#[=============================================================================[
# The soap extension

Configure the `soap` extension.

This extension provides support for writing SOAP servers and clients.

## PHP_EXT_SOAP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SOAP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionSoap
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_SOAP "Enable the soap extension")

add_feature_info(
  "ext/soap"
  PHP_EXT_SOAP
  "SOAP servers and clients support"
)

cmake_dependent_option(
  PHP_EXT_SOAP_SHARED
  "Build the soap extension as a shared library"
  OFF
  PHP_EXT_SOAP
  OFF
)

if(NOT PHP_EXT_SOAP)
  return()
endif()

if(PHP_EXT_SOAP_SHARED)
  add_library(php_ext_soap MODULE)
else()
  add_library(php_ext_soap OBJECT)
endif()

target_sources(
  php_ext_soap
  PRIVATE
    php_encoding.c
    php_http.c
    php_packet_soap.c
    php_schema.c
    php_sdl.c
    php_xml.c
    soap.c
    soap.stub.php
)

target_compile_definitions(
  php_ext_soap
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

include(PHP/Package/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the soap extension."
)

target_link_libraries(php_ext_soap PRIVATE LibXml2::LibXml2)

add_dependencies(php_ext_soap php_ext_hash php_ext_libxml php_ext_random)

if(PHP_EXT_SESSION)
  add_dependencies(php_ext_soap php_ext_session)
endif()

set(HAVE_PHP_SOAP TRUE)
set(HAVE_SOAP TRUE)

configure_file(cmake/config.h.in config.h)
