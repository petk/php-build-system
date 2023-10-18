include(CMakeDependentOption)

option(EXT_EXIF "Whether to enable exif (metadata from images) support" OFF)

cmake_dependent_option(
  EXT_EXIF_SHARED
  "Whether to build the exif extension as shared object"
  OFF
  "EXT_EXIF;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_EXIF)
  return()
endif()

if(EXT_EXIF_SHARED)
  set(_type "SHARED")
endif()

add_library(php_exif ${_type}
  exif.c
)

target_compile_definitions(php_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
