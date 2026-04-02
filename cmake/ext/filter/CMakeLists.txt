#[=============================================================================[
# The filter extension

This extension provides support for data filtering.

## Configuration options

### PHP_EXT_FILTER

* Default: `ON`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_FILTER
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_FILTER "Enable the filter extension" ON)

add_feature_info(
  "ext/filter"
  PHP_EXT_FILTER
  "data filtering support"
)

if(NOT PHP_EXT_FILTER)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(filter)

if(PHP_EXT_FILTER STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_filter MODULE)
else()
  add_library(php_ext_filter OBJECT)
endif()

target_sources(
  php_ext_filter
  PRIVATE
    callback_filter.c
    filter.c
    filter.stub.php
    logical_filters.c
    sanitizing_filters.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_filter.h
)

target_include_directories(php_ext_filter PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(php_ext_filter PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

set_property(
  TARGET php_ext_filter
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pcre
)
