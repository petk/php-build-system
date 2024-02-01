include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ZEND_TEST "Enable the zend_test extension" OFF)

add_feature_info(
  "ext/zend_test"
  EXT_ZEND_TEST
  "Additional support for testing PHP."
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
    iterators.c
    object_handlers.c
    observer.c
    test.c
)

target_compile_definitions(php_zend_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# If ext/libxml is enabled, link libxml library.
if(EXT_LIBXML)
  find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
  set_package_properties(
    LibXml2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to add XML support to zend_test extension."
  )

  target_link_libraries(php_zend_test PRIVATE LibXml2::LibXml2)
endif()
