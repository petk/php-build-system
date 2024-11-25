#[=============================================================================[
# The xmlwriter extension

Configure the `xmlwriter` extension.

This extension provides support for libxml xmlWriter API.

## EXT_XMLWRITER

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_XMLWRITER_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionXmlWriter
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_XMLWRITER "Enable the xmlwriter extension" ON)

add_feature_info(
  "ext/xmlwriter"
  EXT_XMLWRITER
  "support for libxml xmlWriter API"
)

cmake_dependent_option(
  EXT_XMLWRITER_SHARED
  "Build the xmlwriter extension as a shared library"
  OFF
  "EXT_XMLWRITER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_XMLWRITER)
  return()
endif()

if(EXT_XMLWRITER_SHARED)
  add_library(php_xmlwriter SHARED)
else()
  add_library(php_xmlwriter)
endif()

target_sources(
  php_xmlwriter
  PRIVATE
    php_xmlwriter.c
    php_xmlwriter.stub.php
)

target_compile_definitions(
  php_xmlwriter
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the xmlwriter extension."
)

target_link_libraries(php_xmlwriter PRIVATE LibXml2::LibXml2)

# The libxml extension is not technically required for xmlwriter to work but it
# ensures proper error reporting and support for streams.
add_dependencies(php_xmlwriter php_libxml)

set(HAVE_XMLWRITER TRUE)

configure_file(config.cmake.h.in config.h)
