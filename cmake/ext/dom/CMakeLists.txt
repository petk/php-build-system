include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_DOM "Enable the dom extension" ON)

add_feature_info(
  "ext/dom"
  EXT_DOM
  "Support for operations on XML and HTML through Document Object Model (DOM)."
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
    processinginstruction.c
    text.c
    xpath.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        xml_common.h
)

target_compile_definitions(
  php_dom
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the dom extension."
)

target_link_libraries(php_dom PRIVATE LibXml2::LibXml2)

set_target_properties(php_dom PROPERTIES PHP_EXTENSION_DEPENDENCIES php_libxml)

install(
  TARGETS php_dom
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
