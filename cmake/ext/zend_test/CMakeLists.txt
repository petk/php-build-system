include(CMakeDependentOption)

option(EXT_ZEND_TEST "Enable the zend_test extension" OFF)

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
  set(_type "SHARED")
endif()

add_library(php_zend_test ${_type}
  test.c
  observer.c
  fiber.c
  iterators.c
  object_handlers.c
)

target_compile_definitions(php_zend_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# If ext/libxml is enabled, link libxml library.
if(HAVE_LIBXML)
  find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

  target_link_libraries(php_zend_test PRIVATE LibXml2::LibXml2)
endif()
