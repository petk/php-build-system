include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_BZ2 "Enable the bz2 extension" OFF)

add_feature_info(
  "ext/bz2"
  EXT_BZ2
  "Support for reading and writing BZip2 (.bz2) compressed files"
)

cmake_dependent_option(
  EXT_BZ2_SHARED
  "Build the bz2 extension as a shared library"
  OFF
  "EXT_BZ2;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_BZ2)
  return()
endif()

if(EXT_BZ2_SHARED)
  add_library(php_bz2 SHARED)
else()
  add_library(php_bz2)
endif()

target_sources(
  php_bz2
  PRIVATE
    bz2_filter.c
    bz2.c
    bz2.stub.php
)

target_compile_definitions(
  php_bz2
  PRIVATE
    $<$<AND:$<PLATFORM_ID:Windows>,$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>:PHP_BZ2_EXPORTS>
)

find_package(BZip2 ${PHP_BZIP2_MIN_VERSION})
set_package_properties(
  BZip2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the bz2 extension."
)

# Link with PUBLIC scope if include directories are on non-standard places.
target_link_libraries(php_bz2 PUBLIC BZip2::BZip2)

# Sanity check.
if(TARGET BZip2::BZip2)
  check_library_exists(BZip2::BZip2 BZ2_bzerror "" _HAVE_BZ2_BZERROR)

  if(NOT _HAVE_BZ2_BZERROR)
    message(
      FATAL_ERROR
      "BZip2 package is not working as expected. The bz2 extension requires "
      "BZip2 library (libbzip2) version ${PHP_BZIP2_MIN_VERSION} or later. "
      "Please see the CMake logs."
    )
  endif()
endif()
