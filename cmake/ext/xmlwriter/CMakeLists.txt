include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_XMLWRITER "Enable the xmlwriter extension" ON)

add_feature_info("ext/xmlwriter" EXT_XMLWRITER
  "Support for libxml xmlWriter API."
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

target_sources(php_xmlwriter PRIVATE
  php_xmlwriter.c
)

target_compile_definitions(
  php_xmlwriter
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(LibXml2 PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the xmlwriter extension."
)

target_link_libraries(php_xmlwriter PRIVATE LibXml2::LibXml2)

set_target_properties(
  php_xmlwriter
  PROPERTIES PHP_EXTENSION_DEPENDENCIES php_libxml
)
