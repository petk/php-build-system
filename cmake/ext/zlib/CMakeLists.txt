include(CMakeDependentOption)

option(EXT_ZLIB "Enable the zlib extension (requires zlib >= 1.2.0.4)" OFF)

cmake_dependent_option(
  EXT_ZLIB_SHARED
  "Build the zlib extension as a shared library"
  OFF
  "EXT_ZLIB;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ZLIB)
  return()
endif()

if(EXT_ZLIB_SHARED)
  add_library(php_zlib SHARED)
else()
  add_library(php_zlib)
endif()

target_sources(php_zlib PRIVATE
  zlib.c
  zlib_fopen_wrapper.c
  zlib_filter.c
)

target_compile_definitions(php_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(ZLIB 1.2.0.4 REQUIRED)

target_link_libraries(php_zlib PRIVATE ZLIB::ZLIB)
