include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ZLIB "Enable the zlib extension" OFF)

add_feature_info(
  "ext/zlib"
  EXT_ZLIB
  "Support for reading and writing gzip (.gz) compressed files"
)

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

target_sources(
  php_zlib
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:php_zlib.def>
    zlib_filter.c
    zlib_fopen_wrapper.c
    zlib.c
)

target_compile_definitions(php_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(ZLIB 1.2.0.4)
set_package_properties(
  ZLIB
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the zlib extension."
)

target_link_libraries(php_zlib PRIVATE ZLIB::ZLIB)
