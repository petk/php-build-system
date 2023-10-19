include(CMakeDependentOption)

option(EXT_SIMPLEXML "Enable the simplexml extension" ON)

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
  set(_type "SHARED")
endif()

add_library(php_simplexml ${_type}
  simplexml.c
)

set_property(
  TARGET php_simplexml
  PROPERTY PHP_EXT_DEPENDS php_libxml
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_simplexml PRIVATE LibXml2::LibXml2)

target_sources(
  php_simplexml
  PUBLIC FILE_SET simplexml_headers
  TYPE HEADERS
  FILES
    php_simplexml.h
    php_simplexml_exports.h
)

install(
  TARGETS php_simplexml
  FILE_SET simplexml_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/simplexml
)
