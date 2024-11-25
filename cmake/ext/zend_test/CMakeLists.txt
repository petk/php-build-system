#[=============================================================================[
# The zend_test extension

Configure the `zend_test` extension.

This extension provides additional support for testing PHP itself.

## EXT_ZEND_TEST

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_ZEND_TEST_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionZendTest
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ZEND_TEST "Enable the zend_test extension")

add_feature_info(
  "ext/zend_test"
  EXT_ZEND_TEST
  "additional support when testing PHP build"
)

cmake_dependent_option(
  EXT_ZEND_TEST_SHARED
  "Build the zend_test extension as a shared library"
  OFF
  "EXT_ZEND_TEST;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ZEND_TEST)
  return()
endif()

if(EXT_ZEND_TEST_SHARED)
  add_library(php_zend_test SHARED)
else()
  add_library(php_zend_test)
endif()

target_sources(
  php_zend_test
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
)

target_compile_definitions(
  php_zend_test
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    # TODO: PHP_ZEND_TEST_EXPORTS is currently unused.
    $<$<PLATFORM_ID:Windows>:PHP_ZEND_TEST_EXPORTS>
)

# If libxml extension is enabled, link libxml library as headers are used.
# TODO: Reconfigure this for static/shared LibXml library on Windows.
if(EXT_LIBXML)
  include(Packages/LibXml2)

  set_package_properties(
    LibXml2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to add XML support to zend_test extension."
  )

  target_link_libraries(php_zend_test PRIVATE LibXml2::LibXml2)
endif()
