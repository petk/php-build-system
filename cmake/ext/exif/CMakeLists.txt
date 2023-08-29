include(CMakeDependentOption)

option(EXT_EXIF "Whether to enable exif (metadata from images) support" OFF)

cmake_dependent_option(EXT_EXIF_SHARED "Whether to build the exif extension as shared object" OFF "EXT_EXIF;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_EXIF)
  return()
endif()

project(ext_exif VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "Exif PHP extension")

if(EXT_EXIF_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME exif ${_library_type})

add_library(ext_exif ${_library_type}
  exif.c
)

target_include_directories(
  ext_exif
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
