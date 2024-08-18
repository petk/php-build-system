include(CheckCompilerFlag)
include(CheckIncludeFile)

# Check for headers needed by timelib.
check_include_file(io.h HAVE_IO_H)

add_library(php_date STATIC)

# A list of bundled timelib source files.
set(
  php_date_timelib_sources
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/astro.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/dow.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/interval.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/parse_date.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/parse_iso_intervals.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/parse_posix.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/parse_tz.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/timelib.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/tm2unixtime.c
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/unixtime2tm.c
)

target_sources(
  php_date
  PRIVATE
    ${php_date_timelib_sources}
    php_date.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        lib/timelib.h
        php_date.h
  # A separate file set so binary dir can also be created within a source dir.
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/lib/timelib_config.h
)

target_include_directories(php_date PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/lib)

# Suppress possible -Wundef warnings produced by the bundled timelib if such
# warning level is set by the compiler. On Windows MSVC the warning C4668 is
# equivalent to GCC or Clang's -Wundef.
check_compiler_flag(C -Wno-undef _HAVE_WNO_UNDEF_C)

set(
  php_date_timelib_compile_options
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/wd4668>
    $<IF:$<BOOL:${_HAVE_WNO_UNDEF_C}>,-Wno-undef,>
)

set_source_files_properties(
  ${php_date_timelib_sources}
  PROPERTIES
    COMPILE_OPTIONS
      "${php_date_timelib_compile_options}"
)

target_compile_options(
  php_date
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/wd4244>
)

target_compile_definitions(
  php_date
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    HAVE_TIMELIB_CONFIG_H=1
    # The timelib uses C99 strtoll() function conditionally.
    HAVE_STRTOLL
)

set(HAVE_TIMELIB_CONFIG_H 1 CACHE INTERNAL "Whether you have timelib_config.h.")

message(STATUS "Creating ext/date/lib/timelib_config.h")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/lib/timelib_config.h [[
#ifdef PHP_WIN32
# include "config.w32.h"
#else
# include <php_config.h>
#endif
#include <inttypes.h>
#include <stdint.h>

#include "zend.h"

#define timelib_malloc  emalloc
#define timelib_realloc erealloc
#define timelib_calloc  ecalloc
#define timelib_strdup  estrdup
#define timelib_strndup estrndup
#define timelib_free    efree
]])
