option(dl_test "Whether to enable the dl_test extension" OFF)

if(NOT dl_test)
  return()
endif()

project(ext_dl_test VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "The dl_test extension intended for testing dl()")

string(TOLOWER ${dl_test} dl_test_lower)
set(dl_test_library_type "STATIC")
if(dl_test_lower STREQUAL "shared")
  set(dl_test_library_type "SHARED")
endif()

php_extension(NAME dl_test ${dl_test_library_type})

add_library(ext_dl_test ${dl_test_library_type}
  dl_test.c
)

target_include_directories(
  ext_dl_test
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_dl_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
