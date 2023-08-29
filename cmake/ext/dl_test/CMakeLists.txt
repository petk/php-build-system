include(CMakeDependentOption)

option(EXT_DL_TEST "Whether to enable the dl_test extension" OFF)

cmake_dependent_option(EXT_DL_TEST_SHARED "Whether to build the dl_test extension as shared object" OFF "EXT_DL_TEST;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_DL_TEST)
  return()
endif()

project(ext_dl_test VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "The dl_test extension intended for testing dl()")

if(EXT_DL_TEST_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME dl_test ${_library_type})

add_library(ext_dl_test ${_library_type}
  dl_test.c
)

target_include_directories(
  ext_dl_test
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_dl_test PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
