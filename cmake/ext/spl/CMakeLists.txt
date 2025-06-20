#[=============================================================================[
# The spl extension

Configure the `spl` extension.

This extension includes Standard PHP Library (SPL) and is always enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  php_ext_spl
  LANGUAGES C
)

include(FeatureSummary)

add_feature_info(
  "ext/spl"
  TRUE
  "Standard PHP library (SPL)"
)

add_library(php_ext_spl OBJECT)

target_sources(
  php_ext_spl
  PRIVATE
    php_spl.c
    php_spl.stub.php
    spl_array.c
    spl_array.stub.php
    spl_directory.c
    spl_directory.stub.php
    spl_dllist.c
    spl_dllist.stub.php
    spl_exceptions.c
    spl_exceptions.stub.php
    spl_fixedarray.c
    spl_fixedarray.stub.php
    spl_functions.c
    spl_heap.c
    spl_heap.stub.php
    spl_iterators.c
    spl_iterators.stub.php
    spl_observer.c
    spl_observer.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_spl.h
        spl_array.h
        spl_directory.h
        spl_dllist.h
        spl_exceptions.h
        spl_fixedarray.h
        spl_functions.h
        spl_heap.h
        spl_iterators.h
        spl_observer.h
)

target_compile_definitions(php_ext_spl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

add_dependencies(php_ext_spl php_ext_json php_ext_pcre php_ext_standard)
