#[=============================================================================[
# The xml extension

Configure the `xml` extension.

This extension provides support for parsing XML.

## EXT_XML

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_XML_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_XML_EXPAT

* Default: `OFF`
* Values: `ON|OFF`

Build xml extension with the Expat library support instead of the libxml2.
#]=============================================================================]

project(
  PhpExtensionXml
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_XML "Enable the xml extension" ON)

add_feature_info(
  "ext/xml"
  EXT_XML
  "support for parsing XML"
)

cmake_dependent_option(
  EXT_XML_SHARED
  "Build the xml extension as a shared library"
  OFF
  "EXT_XML;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_XML_EXPAT
  "Build xml extension with the Expat library support instead of the libxml2"
  OFF
  "EXT_XML"
  OFF
)

add_feature_info(
  "ext/xml Expat"
  EXT_XML_EXPAT
  "XML support with the Expat library instead of the libxml2"
)

if(NOT EXT_XML)
  return()
endif()

if(EXT_XML_SHARED)
  add_library(php_xml SHARED)
else()
  add_library(php_xml)
endif()

target_sources(
  php_xml
  PRIVATE
    xml.c
    xml.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        expat_compat.h
        php_xml.h
)

target_compile_definitions(php_xml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(NOT EXT_LIBXML AND NOT EXT_XML_EXPAT)
  message(
    FATAL_ERROR
    "The xml extension requires either libxml extension or Expat library. Set "
    "EXT_LIBXML=ON or EXT_XML_EXPAT=ON"
  )
endif()

if(NOT EXT_XML_EXPAT)
  target_sources(php_xml PRIVATE compat.c)

  target_compile_definitions(
    php_xml
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

  target_link_libraries(php_xml PRIVATE LibXml2::LibXml2)

  add_dependencies(php_xml php_libxml)
else()
  find_package(EXPAT)
  set_package_properties(
    EXPAT
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the xml extension."
  )

  target_link_libraries(php_xml PRIVATE EXPAT::EXPAT)

  set(HAVE_LIBEXPAT 1)
endif()

set(HAVE_XML 1)

configure_file(config.cmake.h.in config.h)
