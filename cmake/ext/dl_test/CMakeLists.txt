#[=============================================================================[
# The dl_test extension

Configure the `dl_test` extension.

This extension provides support for testing PHP `dl()` function relevant when
running PHP tests during development.

## PHP_EXT_DL_TEST

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

This extension is always built as shared when enabled.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_DL_TEST
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_DL_TEST "Enable the dl_test extension")

add_feature_info(
  "ext/dl_test"
  PHP_EXT_DL_TEST
  "dl() function testing"
)

if(NOT PHP_EXT_DL_TEST)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(dl_test)

# The dl_test extension can be built only as a shared library.
add_library(php_ext_dl_test MODULE)
target_sources(
  php_ext_dl_test
  PRIVATE
    dl_test.c
    dl_test.stub.php
)

target_compile_definitions(
  php_ext_dl_test
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    # TODO: PHP_DL_TEST_EXPORTS is currently unused.
    $<$<AND:$<PLATFORM_ID:Windows>,$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:PHP_DL_TEST_EXPORTS>
)
