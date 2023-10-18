include(CMakeDependentOption)

option(EXT_XMLWRITER "Whether to enable the xmlwriter extension" ON)

cmake_dependent_option(
  EXT_XMLWRITER_SHARED
  "Whether to build the xmlwriter extension as shared object"
  OFF
  "EXT_XMLWRITER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_XMLWRITER)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "XMLWriter extension requires LIBXML extension, set EXT_LIBXML=ON")
endif()

if(EXT_XMLWRITER_SHARED)
  set(_type "SHARED")
endif()

add_library(php_xmlwriter ${_type}
  php_xmlwriter.c
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_xmlwriter PRIVATE LibXml2::LibXml2)

set_target_properties(php_xmlwriter PROPERTIES PHP_EXT_DEPENDS php_libxml)
