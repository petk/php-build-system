#[=============================================================================[
# The xmlreader extension

This extension provides support for for XML pull parser.

### PHP_EXT_XMLREADER

* Default: `ON`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_XMLREADER_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_XMLREADER
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_XMLREADER "Enable the xmlreader extension" ON)

add_feature_info(
  "ext/xmlreader"
  PHP_EXT_XMLREADER
  "XML pull parser support"
)

cmake_dependent_option(
  PHP_EXT_XMLREADER_SHARED
  "Build the xmlreader extension as a shared library"
  ${PROJECT_IS_TOP_LEVEL}
  PHP_EXT_XMLREADER
  OFF
)

if(NOT PHP_EXT_XMLREADER)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(xmlreader)

if(PHP_EXT_XMLREADER_SHARED OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_xmlreader MODULE)
else()
  add_library(php_ext_xmlreader OBJECT)
endif()

target_sources(
  php_ext_xmlreader
  PRIVATE
    php_xmlreader.c
    php_xmlreader.stub.php
)

target_include_directories(php_ext_xmlreader PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_xmlreader
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>>>:LIBXML_STATIC>
)

include(PHP/Package/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the xmlreader extension."
)

target_link_libraries(php_ext_xmlreader PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_ext_xmlreader
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS libxml
)

set_property(
  TARGET php_ext_xmlreader
  APPEND
  PROPERTY PHP_OPTIONAL_EXTENSIONS dom
)

set(HAVE_XMLREADER TRUE)

configure_file(cmake/config.h.in config.h)
