option(zend_test "Whether to enable the zend_test extension" OFF)

if(NOT zend_test)
  return()
endif()

string(TOLOWER ${zend_test} zend_test_lower)
set(zend_test_library_type "STATIC")
if(zend_test_lower STREQUAL "shared")
  set(zend_test_library_type "SHARED")
endif()

php_extension(NAME "zend_test" ${zend_test_library_type})

add_library(ext_zend_test ${zend_test_library_type}
  test.c
  observer.c
  fiber.c
  object_handlers.c
)

target_compile_definitions(ext_zend_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# If ext/libxml is enabled, link it.
if(HAVE_LIBXML)
  target_link_libraries(ext_zend_test PRIVATE ext_libxml)
endif()
