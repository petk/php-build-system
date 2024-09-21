include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_EXIF "Enable the exif extension" OFF)

add_feature_info(
  "ext/exif"
  EXT_EXIF
  "Support for working with exchangeable image metadata"
)

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

target_sources(
  php_exif
  PRIVATE
    exif.c
)

target_compile_definitions(php_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Exif extension optionally depends on the mbstring extension when decoding
# multibyte data in EXIF tags.
if(EXT_MBSTRING)
  add_dependencies(php_exif php_mbstring)
endif()
