include(CMakeDependentOption)

option(EXT_XML "Whether to enable the XML extension" ON)

cmake_dependent_option(
  EXT_XML_SHARED
  "Whether to build the XML extension as shared object"
  OFF
  "EXT_XML;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_XML_EXPAT
  "Whether to build with Expat support instead of libxml2"
  OFF
  "EXT_XML"
  OFF
)

if(NOT EXT_XML)
  return()
endif()

if(EXT_XML_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "xml" ${_library_type})

add_library(php_xml ${_library_type}
  xml.c
)

if(NOT EXT_XML_EXPAT AND NOT EXT_LIBXML)
  message(FATAL_ERROR "XML extension requires either LIBXML extension or Expat library, set EXT_LIBXML=ON or EXT_XML_EXPAT=ON")
endif()

if(NOT EXT_XML_EXPAT)
  target_sources(php_xml PRIVATE compat.c)

  target_link_libraries(php_xml PRIVATE php_libxml)
else()
  find_package(EXPAT REQUIRED)

  target_link_libraries(php_xml PRIVATE EXPAT::EXPAT)

  set(HAVE_LIBEXPAT 1 CACHE INTERNAL "Whether libexpat is used")
endif()

target_compile_definitions(php_xml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_sources(
  php_xml
  PUBLIC FILE_SET xml_headers
  TYPE HEADERS
  FILES
    expat_compat.h
    php_xml.h
    xml_arginfo.h
)

install(
  TARGETS php_xml
  FILE_SET xml_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/xml
)
