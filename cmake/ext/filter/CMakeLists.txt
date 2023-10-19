include(CMakeDependentOption)

option(EXT_FILTER "Enable the filter extension" ON)

cmake_dependent_option(
  EXT_FILTER_SHARED
  "Build the filter extension as a shared library"
  OFF
  "EXT_FILTER;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_FILTER)
  return()
endif()

if(EXT_FILTER_SHARED)
  set(_type "SHARED")
endif()

add_library(php_filter ${_type}
  filter.c
  sanitizing_filters.c
  logical_filters.c
  callback_filter.c
)

target_compile_definitions(php_filter PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_sources(
  php_filter
  PUBLIC FILE_SET filter_headers
  TYPE HEADERS
  FILES php_filter.h
)

install(
  TARGETS php_filter
  FILE_SET filter_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/filter
)
