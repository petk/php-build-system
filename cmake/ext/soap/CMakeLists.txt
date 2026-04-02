#[=============================================================================[
# The soap extension

This extension provides support for writing SOAP servers and clients.

## Configuration options

### PHP_EXT_SOAP

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_SOAP
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_SOAP "Enable the soap extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/soap"
  PHP_EXT_SOAP
  "SOAP servers and clients support"
)

if(NOT PHP_EXT_SOAP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(soap)

if(PHP_EXT_SOAP STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
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

target_include_directories(php_ext_soap PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_soap
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>>>:LIBXML_STATIC>
)

include(PHP/Package/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the soap extension."
)

target_link_libraries(php_ext_soap PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_ext_soap
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS hash libxml random
)

set_property(
  TARGET php_ext_soap
  APPEND
  PROPERTY PHP_OPTIONAL_EXTENSIONS session
)

set(HAVE_PHP_SOAP TRUE)
set(HAVE_SOAP TRUE)

configure_file(cmake/config.h.in config.h)
