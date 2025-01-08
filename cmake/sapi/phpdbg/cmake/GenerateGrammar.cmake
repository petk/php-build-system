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
  php_sapi_phpdbg_parser
  phpdbg_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
  HEADER
  ADD_DEFAULT_OPTIONS
  ${verbose}
  CODEGEN
)

include(PHP/Re2c)

php_re2c(
  php_sapi_phpdbg_lexer
  phpdbg_lexer.l
  ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
  ADD_DEFAULT_OPTIONS
  OPTIONS
    --bit-vectors
    --conditions
    --debug-output
    --flex-syntax
  CODEGEN
)
