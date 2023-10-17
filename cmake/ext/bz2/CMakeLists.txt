include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_BZ2 "Whether to enable the BZ2 extension" OFF)

cmake_dependent_option(
  EXT_BZ2_SHARED
  "Whether to build the BZ2 extension as shared"
  OFF
  "EXT_BZ2;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_BZ2)
  return()
endif()

if(EXT_BZ2_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_bz2 ${_library_type}
  bz2.c
  bz2_filter.c
)

find_package(BZip2 1.0.0 REQUIRED)

# Link with PUBLIC scope if include directories are on non-standard places.
target_link_libraries(php_bz2 PUBLIC BZip2::BZip2)

# Sanity check.
check_library_exists(BZip2::BZip2 BZ2_bzerror "" HAVE_BZ2_LIB)

if(NOT HAVE_BZ2_LIB)
  message(FATAL_ERROR "bz2 module requires libbz2 >= 1.0.0")
endif()
