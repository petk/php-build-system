#[=============================================================================[
# The xml extension

Configure the `xml` extension.

This extension provides support for parsing XML.

## PHP_EXT_XML

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_XML_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_XML_EXPAT

* Default: `OFF`
* Values: `ON|OFF`

Build xml extension with the Expat library support instead of the libxml2.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_XML
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_XML "Enable the xml extension" ON)

add_feature_info(
  "ext/xml"
  PHP_EXT_XML
  "support for parsing XML"
)

cmake_dependent_option(
  PHP_EXT_XML_SHARED
  "Build the xml extension as a shared library"
  OFF
  PHP_EXT_XML
  OFF
)

cmake_dependent_option(
  PHP_EXT_XML_EXPAT
  "Build xml extension with the Expat library support instead of the libxml2"
  OFF
  PHP_EXT_XML
  OFF
)

add_feature_info(
  "ext/xml Expat"
  PHP_EXT_XML_EXPAT
  "XML support with the Expat library instead of the libxml2"
)

if(NOT PHP_EXT_XML)
  return()
endif()

if(PHP_EXT_XML_SHARED)
  add_library(php_ext_xml MODULE)
else()
  add_library(php_ext_xml OBJECT)
endif()

target_sources(
  php_ext_xml
  PRIVATE
    xml.c
    xml.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        expat_compat.h
        php_xml.h
)

target_compile_definitions(php_ext_xml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(NOT PHP_EXT_LIBXML AND NOT PHP_EXT_XML_EXPAT)
  message(
    FATAL_ERROR
    "The xml extension requires either libxml extension or Expat library. Set "
    "'PHP_EXT_LIBXML' to 'ON', or 'PHP_EXT_XML_EXPAT' to 'ON'."
  )
endif()

if(NOT PHP_EXT_XML_EXPAT)
  target_sources(php_ext_xml PRIVATE compat.c)

  target_compile_definitions(
    php_ext_xml
    PRIVATE
      # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package
      $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
  )

  include(Packages/LibXml2)

  set_package_properties(
    LibXml2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the xml extension."
  )

  target_link_libraries(php_ext_xml PRIVATE LibXml2::LibXml2)

  add_dependencies(php_ext_xml php_ext_libxml)
else()
  find_package(EXPAT)
  set_package_properties(
    EXPAT
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the xml extension."
  )

  target_link_libraries(php_ext_xml PRIVATE EXPAT::EXPAT)

  set(HAVE_LIBEXPAT TRUE)
endif()

set(HAVE_XML TRUE)

configure_file(cmake/config.h.in config.h)
