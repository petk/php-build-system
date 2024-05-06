include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_FILTER "Enable the filter extension" ON)

add_feature_info(
  "ext/filter"
  EXT_FILTER
  "Data filtering support"
)

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
  add_library(php_filter SHARED)
else()
  add_library(php_filter)
endif()

target_sources(
  php_filter
  PRIVATE
    callback_filter.c
    filter.c
    logical_filters.c
    sanitizing_filters.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_filter.h
)

target_compile_definitions(php_filter PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

add_dependencies(php_filter php_pcre)
