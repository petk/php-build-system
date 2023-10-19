include(CMakeDependentOption)

option(EXT_XMLREADER "Enable the xmlreader extension" ON)

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
  set(_type "SHARED")
endif()

add_library(php_xmlreader ${_type}
  php_xmlreader.c
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_xmlreader PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_xmlreader
  PROPERTY PHP_EXT_DEPENDS php_libxml php_dom
)
