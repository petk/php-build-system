#[=============================================================================[
# The zend_test extension

Configure the `zend_test` extension.

This extension provides additional support for testing PHP itself.

## PHP_EXT_ZEND_TEST

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_ZEND_TEST_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_ZEND_TEST
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_ZEND_TEST "Enable the zend_test extension")

add_feature_info(
  "ext/zend_test"
  PHP_EXT_ZEND_TEST
  "additional PHP build testing support"
)

cmake_dependent_option(
  PHP_EXT_ZEND_TEST_SHARED
  "Build the zend_test extension as a shared library"
  OFF
  PHP_EXT_ZEND_TEST
  OFF
)

if(NOT PHP_EXT_ZEND_TEST)
  return()
endif()

if(PHP_EXT_ZEND_TEST_SHARED)
  add_library(php_ext_zend_test MODULE)
else()
  add_library(php_ext_zend_test OBJECT)
endif()

target_sources(
  php_ext_zend_test
  PRIVATE
    fiber.c
    fiber.stub.php
    iterators.c
    iterators.stub.php
    object_handlers.c
    object_handlers.stub.php
    observer.c
    test.c
    test.stub.php
    zend_mm_custom_handlers.c
)

target_compile_definitions(
  php_ext_zend_test
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    # TODO: PHP_ZEND_TEST_EXPORTS is currently unused.
    $<$<PLATFORM_ID:Windows>:PHP_ZEND_TEST_EXPORTS>
)

# TODO: Fix this better.
# If libxml extension is enabled, link libxml library as headers are used.
# TODO: Reconfigure this for static/shared LibXml library on Windows.
if(PHP_EXT_LIBXML)
  include(Packages/LibXml2)

  set_package_properties(
    LibXml2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to add XML support to zend_test extension."
  )

  target_link_libraries(php_ext_zend_test PRIVATE LibXml2::LibXml2)
endif()
