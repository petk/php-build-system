# Generate lexer and parser files.

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.h
)
  set(PHP_BISON_OPTIONAL TRUE)
endif()
include(PHP/BISON)

php_bison(
  php_sapi_phpdbg_parser
  phpdbg_parser.y
  phpdbg_parser.c
  COMPILE_FLAGS "${PHP_BISON_DEFAULT_OPTIONS}"
  VERBOSE REPORT_FILE phpdbg_parser.output
  DEFINES_FILE phpdbg_parser.h
)

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()
include(PHP/RE2C)

php_re2c(
  php_sapi_phpdbg_lexer
  phpdbg_lexer.l
  ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
  OPTIONS -cbdF
  CODEGEN
)
