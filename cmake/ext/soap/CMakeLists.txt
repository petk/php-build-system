#[=============================================================================[
# The soap extension

Configure the `soap` extension.

This extension provides support for writing SOAP servers and clients.

## EXT_SOAP

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_SOAP_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionSoap
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SOAP "Enable the soap extension")

add_feature_info(
  "ext/soap"
  EXT_SOAP
  "support for writing SOAP servers and clients"
)

cmake_dependent_option(
  EXT_SOAP_SHARED
  "Build the soap extension as a shared library"
  OFF
  "EXT_SOAP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SOAP)
  return()
endif()

if(EXT_SOAP_SHARED)
  add_library(php_soap SHARED)
else()
  add_library(php_soap)
endif()

target_sources(
  php_soap
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
  php_soap
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the soap extension."
)

target_link_libraries(php_soap PRIVATE LibXml2::LibXml2)

add_dependencies(php_soap php_date php_hash php_libxml php_random)

if(EXT_SESSION)
  add_dependencies(php_soap php_session)
endif()

set(HAVE_SOAP TRUE)

configure_file(config.cmake.h.in config.h)
