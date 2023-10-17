include(CMakeDependentOption)

option(EXT_XMLREADER "Whether to enable the xmlreader extension" ON)

cmake_dependent_option(
  EXT_XMLREADER_SHARED
  "Whether to build the xmlreader extension as shared object"
  OFF
  "EXT_XMLREADER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_XMLREADER)
  return()
endif()

if(EXT_XMLREADER_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_xmlreader ${_library_type}
  php_xmlreader.c
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_xmlreader PRIVATE LibXml2::LibXml2)

set_property(
  TARGET php_xmlreader
  PROPERTY PHP_EXT_DEPENDS php_libxml php_dom
)
