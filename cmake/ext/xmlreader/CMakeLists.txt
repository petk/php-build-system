#[=============================================================================[
# The xmlreader extension

Configure the `xmlreader` extension.

This extension provides support for for XML pull parser.

## PHP_EXT_XMLREADER

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_XMLREADER_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

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
  OFF
  PHP_EXT_XMLREADER
  OFF
)

if(NOT PHP_EXT_XMLREADER)
  return()
endif()

if(PHP_EXT_XMLREADER_SHARED)
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

target_compile_definitions(
  php_ext_xmlreader
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the xmlreader extension."
)

target_link_libraries(php_ext_xmlreader PRIVATE LibXml2::LibXml2)

# Optional dependency.
if(PHP_EXT_DOM)
  add_dependencies(php_ext_xmlreader php_ext_dom)
endif()

add_dependencies(php_ext_xmlreader php_ext_libxml)

set(HAVE_XMLREADER TRUE)

configure_file(cmake/config.h.in config.h)
