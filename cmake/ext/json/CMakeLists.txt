add_library(php_json STATIC)

target_sources(
  php_json
  PRIVATE
    json_encoder.c
    json_parser.tab.c
    json_scanner.c
    json.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_json_parser.h
        php_json_scanner.h
        php_json.h
)

target_compile_definitions(php_json PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(BISON_FOUND)
  bison_target(
    php_json_parser
    "${CMAKE_CURRENT_SOURCE_DIR}/json_parser.y"
    "${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c"
    COMPILE_FLAGS "-Wall --defines -l"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h"
  )
endif()

if(RE2C_FOUND)
  re2c_target(
    NAME php_json_scanner
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c"
    OPTIONS "--no-generation-date -bci -t \"${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h\""
  )
endif()

# HAVE_JSON is always 1 as of php 8.0 and the constant will be removed in the
# future. Note that HAVE_JSON was never defined for Windows builds.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_JSON 1 CACHE INTERNAL "Whether to enable the json extension.")
endif()

install(
  TARGETS php_json
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
