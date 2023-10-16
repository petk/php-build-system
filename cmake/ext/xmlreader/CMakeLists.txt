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

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "XMLReader extension requires LIBXML extension, set EXT_LIBXML=ON")
endif()

if(EXT_XMLREADER_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "xmlreader" ${_library_type})

add_library(php_xmlreader ${_library_type}
  php_xmlreader.c
)

target_link_libraries(php_xmlreader PRIVATE php_libxml)
