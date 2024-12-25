# Generate lexer and parser files.

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
)
  set(PHP_BISON_OPTIONAL TRUE)
endif()

include(PHP/BISON)

php_bison(
  php_ext_json_parser
  json_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
  COMPILE_FLAGS "${PHP_BISON_DEFAULT_OPTIONS}"
  VERBOSE REPORT_FILE json_parser.tab.output
  DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
)

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()

include(PHP/RE2C)

php_re2c(
  php_ext_json_scanner
  json_scanner.re
  ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
  OPTIONS -bc
  CODEGEN
)
