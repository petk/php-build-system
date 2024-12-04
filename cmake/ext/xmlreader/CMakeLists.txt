#[=============================================================================[
# The xmlreader extension

Configure the `xmlreader` extension.

This extension provides support for for XML pull parser.

## EXT_XMLREADER

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_XMLREADER_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionXmlReader
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_XMLREADER "Enable the xmlreader extension" ON)

add_feature_info(
  "ext/xmlreader"
  EXT_XMLREADER
  "XML pull parser support"
)

cmake_dependent_option(
  EXT_XMLREADER_SHARED
  "Build the xmlreader extension as a shared library"
  OFF
  "EXT_XMLREADER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_XMLREADER)
  return()
endif()

if(EXT_XMLREADER_SHARED)
  add_library(php_xmlreader SHARED)
else()
  add_library(php_xmlreader)
endif()

target_sources(
  php_xmlreader
  PRIVATE
    php_xmlreader.c
    php_xmlreader.stub.php
)

target_compile_definitions(
  php_xmlreader
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

target_link_libraries(php_xmlreader PRIVATE LibXml2::LibXml2)

# Optional dependency.
if(EXT_DOM)
  add_dependencies(php_xmlreader php_dom)
endif()

add_dependencies(php_xmlreader php_libxml)

set(HAVE_XMLREADER TRUE)

configure_file(cmake/config.h.in config.h)
