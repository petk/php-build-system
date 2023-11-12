include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_XMLREADER "Enable the xmlreader extension" ON)

add_feature_info("ext/xmlreader" EXT_XMLREADER
  "Support for XML pull parser."
)

cmake_dependent_option(
  EXT_XMLREADER_SHARED
  "Build the xmlreader extension as a shared library"
  OFF
  "EXT_XMLREADER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_XMLREADER)
  return()
endif()

if(EXT_XMLREADER_SHARED)
  add_library(php_xmlreader SHARED)
else()
  add_library(php_xmlreader)
endif()

target_sources(php_xmlreader PRIVATE
  php_xmlreader.c
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(LibXml2 PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the xmlreader extension."
)

target_link_libraries(php_xmlreader PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_xmlreader
  PROPERTY PHP_EXTENSION_DEPENDENCIES php_libxml php_dom
)
