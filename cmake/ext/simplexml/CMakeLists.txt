project(
  PhpExtensionSimpleXml
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SIMPLEXML "Enable the simplexml extension" ON)

add_feature_info(
  "ext/simplexml"
  EXT_SIMPLEXML
  "Toolset for converting XML to a processable object"
)

cmake_dependent_option(
  EXT_SIMPLEXML_SHARED
  "Build the simplexml extension as a shared library"
  OFF
  "EXT_SIMPLEXML;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SIMPLEXML)
  return()
endif()

if(EXT_SIMPLEXML_SHARED)
  add_library(php_simplexml SHARED)
else()
  add_library(php_simplexml)
endif()

target_sources(
  php_simplexml
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
  php_simplexml
  PRIVATE
    # TODO: Fix LIBXML_STATIC usage based on the static/shared libxml2 package.
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
    $<$<PLATFORM_ID:Windows>:PHP_SIMPLEXML_EXPORTS>
)

add_dependencies(php_simplexml php_libxml php_spl)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the simplexml extension."
)

target_link_libraries(php_simplexml PRIVATE LibXml2::LibXml2)

set(HAVE_SIMPLEXML 1)

configure_file(config.cmake.h.in config.h)
