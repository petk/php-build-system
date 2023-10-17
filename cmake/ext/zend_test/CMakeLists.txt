set_directory_properties(PROPERTIES PHP_PRIORITY 101)

include(CMakeDependentOption)

option(EXT_ZEND_TEST "Whether to enable the zend_test extension" OFF)

cmake_dependent_option(
  EXT_ZEND_TEST_SHARED
  "Whether to build the zend_test extension as shared object"
  OFF
  "EXT_ZEND_TEST;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ZEND_TEST)
  return()
endif()

if(EXT_ZEND_TEST_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_zend_test ${_library_type}
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
