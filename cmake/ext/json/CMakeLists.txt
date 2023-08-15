php_extension(NAME "json")

bison_target(JsonParser
  "${CMAKE_CURRENT_BINARY_DIR}/json_parser.y"
  "${CMAKE_CURRENT_BINARY_DIR}/json_parser.tab.c"
  COMPILE_FLAGS "--defines -l"
  DEFINES_FILE "${CMAKE_CURRENT_BINARY_DIR}/json_parser.tab.h"
)

re2c_target(
  NAME json_scanner.c
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.re"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c"
  OPTIONS "--no-generation-date -bci -t ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h"
)

add_library(ext_json
  json.c
  json_encoder.c
  json_parser.tab.c
  json_scanner.c
  ${BISON_JsonParser_OUTPUTS}
)

target_include_directories(
  ext_json
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(ext_json PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(ext_json PROPERTIES PUBLIC_HEADER "php_json.h;php_json_parser.h;php_json_scanner.h")

# HAVE_JSON is always 1 as of php 8.0 and the constant will be removed in the future.
# Note that HAVE_JSON was never defined for Windows builds.
# TODO: Remove this in the future PHP versions.
if(NOT WIN32)
  set(HAVE_JSON 1 CACHE INTERNAL "Whether to enable JavaScript Object Serialization support")
endif()
