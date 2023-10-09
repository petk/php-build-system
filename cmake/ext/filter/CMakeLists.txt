include(CMakeDependentOption)

option(EXT_FILTER "Whether to enable the filter extension" ON)

cmake_dependent_option(EXT_FILTER_SHARED "Whether to build the filter extension as shared object" OFF "EXT_FILTER;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_FILTER)
  return()
endif()

if(EXT_FILTER_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "filter" ${_library_type})

add_library(filter ${_library_type}
  filter.c
  sanitizing_filters.c
  logical_filters.c
  callback_filter.c
)

target_compile_definitions(filter PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_sources(
  filter
  PUBLIC FILE_SET filter_headers
  TYPE HEADERS
  FILES php_filter.h
)

install(
  TARGETS filter
  FILE_SET filter_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/filter
)
