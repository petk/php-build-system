# Generate parser and lexer files.

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  message(FATAL_ERROR "This file should be used with include().")
endif()

include(PHP/Bison)

if(CMAKE_SCRIPT_MODE_FILE)
  set(verbose "")
else()
  set(verbose VERBOSE)
endif()

php_bison(
  php_ext_json_parser
  json_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
  HEADER
  ADD_DEFAULT_OPTIONS
  ${verbose}
  CODEGEN
)

include(PHP/Re2c)

php_re2c(
  php_ext_json_scanner
  json_scanner.re
  ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
  ADD_DEFAULT_OPTIONS
  OPTIONS --bit-vectors --conditions
  CODEGEN
)
