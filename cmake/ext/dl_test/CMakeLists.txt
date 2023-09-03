include(CMakeDependentOption)

# The dl_test extension can be built either as shared or disabled.
option(EXT_DL_TEST "Whether to enable the dl_test extension" OFF)

if(NOT EXT_DL_TEST)
  return()
endif()

project(ext_dl_test VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "The dl_test extension intended for testing dl()")

php_extension(NAME dl_test SHARED)

add_library(ext_dl_test SHARED
  dl_test.c
)

target_include_directories(
  ext_dl_test
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_dl_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
