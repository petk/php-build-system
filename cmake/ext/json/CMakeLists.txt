php_extension(NAME "json" STATIC)

add_library(ext_json STATIC
  json.c
  json_encoder.c
  json_parser.tab.c
  json_scanner.c
)

if(BISON_FOUND)
  bison_target(JsonParser
    "${CMAKE_CURRENT_SOURCE_DIR}/json_parser.y"
    "${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c"
    COMPILE_FLAGS "--defines -l"
    DEFINES_FILE "${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h"
  )
endif()

if(RE2C_FOUND)
  re2c_target(
    NAME jsonScanner
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c"
    OPTIONS "--no-generation-date -bci -t \"${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h\""
  )
endif()

target_compile_definitions(ext_json PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# HAVE_JSON is always 1 as of php 8.0 and the constant will be removed in the future.
# Note that HAVE_JSON was never defined for Windows builds.
# TODO: Remove this in the future PHP versions.
if(NOT WIN32)
  set(HAVE_JSON 1 CACHE INTERNAL "Whether to enable JavaScript Object Serialization support")
endif()

target_sources(
  ext_json
  PUBLIC FILE_SET ext_json_headers
  TYPE HEADERS
  FILES
    php_json.h
    php_json_parser.h
    php_json_scanner.h
)

install(
  TARGETS ext_json
  FILE_SET ext_json_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/json
)
