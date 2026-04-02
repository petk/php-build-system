#[=============================================================================[
# The dom extension

This extension provides support for operations on XML and HTML through Document
Object Model (DOM).

## Configuration options

### PHP_EXT_DOM

* Default: `ON`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_DOM
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_DOM "Enable the dom extension" ON)

add_feature_info(
  "ext/dom"
  PHP_EXT_DOM
  "XML and HTML operations through Document Object Model (DOM)"
)

if(NOT PHP_EXT_DOM)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(dom)

if(PHP_EXT_DOM STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
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

target_include_directories(php_ext_dom PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_dom
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>>>:LIBXML_STATIC>
)

include(PHP/Package/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the dom extension."
)

target_link_libraries(php_ext_dom PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_ext_dom
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS libxml random
)

set(HAVE_DOM TRUE)

configure_file(cmake/config.h.in config.h)
