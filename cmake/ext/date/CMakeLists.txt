#[=============================================================================[
# The date extension

Configure the `date` extension.

This extension provides date and time support.

This extension is always enabled.
#]=============================================================================]

project(
  PhpExtensionDate
  LANGUAGES C
)

include(FeatureSummary)

add_feature_info(
  "ext/date"
  TRUE
  "date and time"
)

add_library(php_date OBJECT)

target_sources(
  php_date
  PRIVATE
    php_date.c
    php_date.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_date.h
)

target_compile_definitions(php_date PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_compile_options(
  php_date
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/wd4244>
)

# Configure timelib.
set(TIMELIB_TARGET php_date)
add_subdirectory(lib)

set(HAVE_TIMELIB_CONFIG_H TRUE)

file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/lib/timelib_config.h "\n" [[
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

configure_file(cmake/config.h.in config.h)
