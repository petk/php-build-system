include(CMakeDependentOption)

option(EXT_XMLWRITER "Whether to enable the xmlwriter extension" ON)

cmake_dependent_option(EXT_XMLWRITER_SHARED "Whether to build the xmlwriter extension as shared object" OFF "EXT_XMLWRITER;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_XMLWRITER)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "XMLWriter extension requires LIBXML extension, set EXT_LIBXML=ON")
endif()

if(EXT_XMLWRITER_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "xmlwriter" ${_library_type})

add_library(xmlwriter ${_library_type}
  php_xmlwriter.c
)

target_link_libraries(xmlwriter PRIVATE libxml)
