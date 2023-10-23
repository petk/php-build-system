include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_BZ2 "Enable the bz2 extension" OFF)

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

target_sources(php_bz2 PRIVATE
  bz2.c
  bz2_filter.c
)

find_package(BZip2 1.0.0 REQUIRED)

# Link with PUBLIC scope if include directories are on non-standard places.
target_link_libraries(php_bz2 PUBLIC BZip2::BZip2)

# Sanity check.
check_library_exists(BZip2::BZip2 BZ2_bzerror "" HAVE_BZ2_LIB)

if(NOT HAVE_BZ2_LIB)
  message(FATAL_ERROR "bz2 extension requires libbz2 >= 1.0.0")
endif()
