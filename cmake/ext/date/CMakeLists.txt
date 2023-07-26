include(CheckIncludeFile)
include(CheckSymbolExists)

php_extension(NAME "date")

# Check for headers needed by timelib.
check_include_file(io.h HAVE_IO_H)

# Check for strtoll, atoll.
check_symbol_exists(atoll "stdlib.h" HAVE_ATOLL)
check_symbol_exists(strtoll "stdlib.h" HAVE_STRTOLL)

add_library(ext_date STATIC
  php_date.c
  lib/astro.c
  lib/dow.c
  lib/parse_date.c
  lib/parse_tz.c
  lib/parse_posix.c
  lib/timelib.c
  lib/tm2unixtime.c
  lib/unixtime2tm.c
  lib/parse_iso_intervals.c
  lib/interval.c
)

target_include_directories(ext_date
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/lib
)

target_compile_options(ext_date PRIVATE
  -Wno-implicit-fallthrough
)

target_compile_definitions(ext_date PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(ext_date PROPERTIES PUBLIC_HEADER "php_date.h;lib/timelib.h;lib/timelib_config.h")

set(HAVE_TIMELIB_CONFIG_H 1 CACHE STRING "Have timelib_config.h")

message(STATUS "Creating ext/date/lib/timelib_config.h")
file(WRITE "lib/timelib_config.h"
"#ifdef PHP_WIN32
# include \"config.w32.h\"
#else
# include <php_config.h>
#endif
#include <inttypes.h>
#include <stdint.h>

#include \"zend.h\"

#define timelib_malloc  emalloc
#define timelib_realloc erealloc
#define timelib_calloc  ecalloc
#define timelib_strdup  estrdup
#define timelib_strndup estrndup
#define timelib_free    efree
")

add_dependencies(ext_date main Zend)
