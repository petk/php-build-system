#[=============================================================================[
# The fileinfo extension

Configure the `fileinfo` extension.

This extension provides support for file content type and encoding.

## PHP_EXT_FILEINFO

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_FILEINFO_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionFileinfo
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckAttribute)

option(PHP_EXT_FILEINFO "Enable the fileinfo extension" ON)

add_feature_info(
  "ext/fileinfo"
  PHP_EXT_FILEINFO
  "file content type and encoding support"
)

cmake_dependent_option(
  PHP_EXT_FILEINFO_SHARED
  "Build the fileinfo extension as a shared library"
  OFF
  "PHP_EXT_FILEINFO;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_FILEINFO)
  return()
endif()

if(PHP_EXT_FILEINFO_SHARED)
  add_library(php_ext_fileinfo SHARED)
else()
  add_library(php_ext_fileinfo)
endif()

target_sources(
  php_ext_fileinfo
  PRIVATE
    fileinfo.c
    fileinfo.stub.php
    libmagic/apprentice.c
    libmagic/apptype.c
    libmagic/ascmagic.c
    libmagic/buffer.c
    libmagic/cdf_time.c
    libmagic/cdf.c
    libmagic/compress.c
    libmagic/der.c
    libmagic/encoding.c
    libmagic/fsmagic.c
    libmagic/funcs.c
    libmagic/is_csv.c
    libmagic/is_json.c
    libmagic/is_tar.c
    libmagic/magic.c
    libmagic/print.c
    libmagic/readcdf.c
    libmagic/softmagic.c
    php_libmagic.c
)

# Check for major, minor, and makedev.
include(PHP/CheckSysMacros)

# The strcasestr is missing on Windows and Solaris <= 10 (Solaris 11 has it).
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(strcasestr string.h HAVE_STRCASESTR)
cmake_pop_check_state()
if(NOT HAVE_STRCASESTR)
  message(STATUS "Using libmagic strcasestr implementation")
  target_sources(php_ext_fileinfo PRIVATE libmagic/strcasestr.c)
endif()

check_symbol_exists(strndup string.h HAVE_STRNDUP)
check_symbol_exists(utimes sys/time.h HAVE_UTIMES)

php_check_function_attribute(visibility HAVE_VISIBILITY)

target_compile_definitions(
  php_ext_fileinfo
  PRIVATE
    # The wchar.h and inttypes.h headers are always available by C99 standard.
    # The libmagic still includes them conditionally.
    HAVE_WCHAR_H=1
    HAVE_INTTYPES_H=1
    $<IF:$<BOOL:${HAVE_VISIBILITY}>,HAVE_VISIBILITY=1,HAVE_VISIBILITY=0>
)

set_property(
  SOURCE libmagic/apprentice.c
  APPEND
  PROPERTY
    OBJECT_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/data_file.c
)

add_dependencies(php_ext_fileinfo php_ext_pcre)

configure_file(cmake/config.h.in config.h)
