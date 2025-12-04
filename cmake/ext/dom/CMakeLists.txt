#[=============================================================================[
# The dom extension

Configure the `dom` extension.

This extension provides support for operations on XML and HTML through Document
Object Model (DOM).

## PHP_EXT_DOM

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_DOM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_DOM
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_DOM "Enable the dom extension" ON)

add_feature_info(
  "ext/dom"
  PHP_EXT_DOM
  "XML and HTML operations through Document Object Model (DOM)"
)

cmake_dependent_option(
  PHP_EXT_DOM_SHARED
  "Build the dom extension as a shared library"
  OFF
  PHP_EXT_DOM
  OFF
)

if(NOT PHP_EXT_DOM)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(dom)

if(PHP_EXT_DOM_SHARED)
  add_library(php_ext_dom MODULE)
else()
  add_library(php_ext_dom OBJECT)
endif()

target_sources(
  php_ext_dom
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
    html_collection.c
    html_document.c
    html5_parser.c
    html5_serializer.c
    infra.c
    inner_outer_html_mixin.c
    lexbor/selectors-adapted/selectors.c
    namednodemap.c
    namespace_compat.c
    node.c
    nodelist.c
    notation.c
    obj_map.c
    parentnode/css_selectors.c
    parentnode/tree.c
    php_dom.c
    php_dom.stub.php
    private_data.c
    processinginstruction.c
    text.c
    token_list.c
    xml_document.c
    xml_serializer.c
    xpath_callbacks.c
    xpath.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        dom_ce.h
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/lexbor/selectors-adapted/selectors.h>
        namespace_compat.h
        xml_common.h
        xpath_callbacks.h
)

target_compile_definitions(
  php_ext_dom
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC;LEXBOR_STATIC>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the dom extension."
)

target_link_libraries(php_ext_dom PRIVATE LibXml2::LibXml2)

add_dependencies(php_ext_dom php_ext_lexbor php_ext_libxml php_ext_random)

set(HAVE_DOM TRUE)

configure_file(cmake/config.h.in config.h)
