include(CheckCCompilerFlag)
include(CheckIncludeFile)
include(CheckSymbolExists)

# Check for headers needed by timelib.
check_include_file(io.h HAVE_IO_H)

# Check for strtoll, atoll.
check_symbol_exists(atoll "stdlib.h" HAVE_ATOLL)
check_symbol_exists(strtoll "stdlib.h" HAVE_STRTOLL)

add_library(php_date STATIC
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
)

target_include_directories(php_date
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/lib
          ${CMAKE_CURRENT_SOURCE_DIR}/lib
  INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/lib
)

check_c_compiler_flag(-Wno-implicit-fallthrough HAVE_WNO_IMPLICIT_FALLTHROUGH)
if(HAVE_WNO_IMPLICIT_FALLTHROUGH)
  target_compile_options(php_date PRIVATE -Wno-implicit-fallthrough)
endif()

target_compile_definitions(php_date
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    HAVE_TIMELIB_CONFIG_H=1
)

set(HAVE_TIMELIB_CONFIG_H 1 CACHE INTERNAL "Have timelib_config.h")

message(STATUS "Creating ext/date/lib/timelib_config.h")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/lib/timelib_config.h"
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

add_dependencies(php_date PHP::main zend)

target_sources(
  php_date
  PUBLIC FILE_SET date_headers
  TYPE HEADERS
  BASE_DIRS "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}"
  FILES
    lib/timelib.h
    "${CMAKE_CURRENT_BINARY_DIR}/lib/timelib_config.h"
    php_date.h
)

install(
  TARGETS php_date
  FILE_SET date_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/date
)
