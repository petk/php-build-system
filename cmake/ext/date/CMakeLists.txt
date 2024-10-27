project(
  PhpExtensionDate
  LANGUAGES C
)

include(CheckIncludeFile)
include(FeatureSummary)

add_feature_info(
  "ext/date"
  ON
  "Date and time"
)

# Check for headers needed by timelib.
check_include_file(io.h HAVE_IO_H)

add_library(php_date STATIC)

target_sources(
  php_date
  PRIVATE
    lib/astro.c
    lib/dow.c
    lib/interval.c
    lib/parse_date.c
    lib/parse_iso_intervals.c
    lib/parse_posix.c
    lib/parse_tz.c
    lib/timelib.c
    lib/tm2unixtime.c
    lib/unixtime2tm.c
    php_date.c
    php_date.stub.php
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

set(HAVE_TIMELIB_CONFIG_H 1)

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

configure_file(config.cmake.h.in config.h @ONLY)
