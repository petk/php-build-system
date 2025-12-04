#[=============================================================================[
# The filter extension

Configure the `filter` extension.

This extension provides support for data filtering.

## PHP_EXT_FILTER

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_FILTER_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_FILTER
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_FILTER "Enable the filter extension" ON)

add_feature_info(
  "ext/filter"
  PHP_EXT_FILTER
  "data filtering support"
)

cmake_dependent_option(
  PHP_EXT_FILTER_SHARED
  "Build the filter extension as a shared library"
  OFF
  PHP_EXT_FILTER
  OFF
)

if(NOT PHP_EXT_FILTER)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(filter)

if(PHP_EXT_FILTER_SHARED)
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

target_compile_definitions(php_ext_filter PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

add_dependencies(php_ext_filter php_ext_pcre)
