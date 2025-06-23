#[=============================================================================[
# The simplexml extension

Configure the `simplexml` extension.

This extension provides toolset for converting XML to a processable object.

## PHP_EXT_SIMPLEXML

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SIMPLEXML_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionSimpleXml
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_SIMPLEXML "Enable the simplexml extension" ON)

add_feature_info(
  "ext/simplexml"
  PHP_EXT_SIMPLEXML
  "toolset for converting XML to a processable object"
)

cmake_dependent_option(
  PHP_EXT_SIMPLEXML_SHARED
  "Build the simplexml extension as a shared library"
  OFF
  "PHP_EXT_SIMPLEXML;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_SIMPLEXML)
  return()
endif()

if(PHP_EXT_SIMPLEXML_SHARED)
  add_library(php_ext_simplexml MODULE)
else()
  add_library(php_ext_simplexml)
endif()

target_sources(
  php_ext_simplexml
  PRIVATE
    simplexml.c
    simplexml.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_simplexml_exports.h
        php_simplexml.h
)

target_compile_definitions(
  php_ext_simplexml
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
    $<$<PLATFORM_ID:Windows>:PHP_SIMPLEXML_EXPORTS>
)

add_dependencies(php_ext_simplexml php_ext_libxml php_ext_spl)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the simplexml extension."
)

target_link_libraries(php_ext_simplexml PRIVATE LibXml2::LibXml2)

set(HAVE_SIMPLEXML TRUE)

configure_file(cmake/config.h.in config.h)
