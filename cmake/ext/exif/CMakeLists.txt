include(CMakeDependentOption)

option(EXT_EXIF "Enable the exif extension (metadata from images)" OFF)

cmake_dependent_option(
  EXT_EXIF_SHARED
  "Build the exif extension as a shared library"
  OFF
  "EXT_EXIF;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_EXIF)
  return()
endif()

if(EXT_EXIF_SHARED)
  add_library(php_exif SHARED)
else()
  add_library(php_exif)
endif()

target_sources(php_exif PRIVATE
  exif.c
)

target_compile_definitions(php_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
