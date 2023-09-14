include(CMakeDependentOption)

option(EXT_XML "Whether to enable the XML extension" ON)

cmake_dependent_option(EXT_XML_SHARED "Whether to build the XML extension as shared object" OFF "EXT_XML;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_XML_EXPAT "Whether to build with expat support instead of libxml2" OFF "EXT_XML" OFF)

if(NOT EXT_XML)
  return()
endif()

if(EXT_XML_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "xml" ${_library_type})

add_library(ext_xml ${_library_type}
  xml.c
)

if(NOT EXT_XML_EXPAT AND NOT EXT_LIBXML)
  message(FATAL_ERROR "XML extension requires LIBXML extension, add EXT_LIBXML=ON")
endif()

if(NOT EXT_XML_EXPAT)
  target_sources(ext_xml PRIVATE compat.c)

  target_link_libraries(ext_xml PRIVATE ext_libxml)
else()
  find_package(EXPAT REQUIRED GLOBAL)

  set(HAVE_LIBEXPAT 1 CACHE INTERNAL "Whether libexpat is used")

  if(EXPAT_LIBRARIES)
    target_link_libraries(ext_xml PRIVATE ${EXPAT_LIBRARIES})
  endif()

  if(EXPAT_INCLUDE_DIRS)
    target_include_directories(ext_xml PRIVATE ${EXPAT_INCLUDE_DIRS})
  endif()
endif()

target_compile_definitions(ext_xml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

file(GLOB _ext_xml_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  ext_xml
  PUBLIC FILE_SET ext_xml_headers
  TYPE HEADERS
  FILES ${_ext_xml_headers}
)

install(
  TARGETS ext_xml
  FILE_SET ext_xml_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/xml
)
