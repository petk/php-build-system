#[=============================================================================[
# The dom extension

Configure the `dom` extension.

## EXT_DOM

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_DOM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionDom
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_DOM "Enable the dom extension" ON)

add_feature_info(
  "ext/dom"
  EXT_DOM
  "Support for operations on XML and HTML through Document Object Model (DOM)"
)

cmake_dependent_option(
  EXT_DOM_SHARED
  "Build the dom extension as a shared library"
  OFF
  "EXT_DOM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_DOM)
  return()
endif()

if(EXT_DOM_SHARED)
  add_library(php_dom SHARED)
else()
  add_library(php_dom)
endif()

target_sources(
  php_dom
  PRIVATE
    attr.c
    cdatasection.c
    characterdata.c
    comment.c
    document.c
    documentfragment.c
    documenttype.c
    dom_iterators.c
    domexception.c
    domimplementation.c
    element.c
    entity.c
    entityreference.c
    namednodemap.c
    node.c
    nodelist.c
    notation.c
    parentnode.c
    php_dom.c
    php_dom.stub.php
    processinginstruction.c
    text.c
    xpath.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        xml_common.h
)

target_compile_definitions(
  php_dom
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the dom extension."
)

target_link_libraries(php_dom PRIVATE LibXml2::LibXml2)

add_dependencies(php_dom php_libxml php_random)

set(HAVE_DOM 1)

configure_file(config.cmake.h.in config.h)
