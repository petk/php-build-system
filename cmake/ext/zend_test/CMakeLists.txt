project(
  PhpExtensionZendTest
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ZEND_TEST "Enable the zend_test extension" OFF)

add_feature_info(
  "ext/zend_test"
  EXT_ZEND_TEST
  "Additional support for testing PHP"
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
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
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

configure_file(config.cmake.h.in config.h @ONLY)
