# Generate lexer files.

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  message(FATAL_ERROR "This file should be used with include().")
endif()

include(PHP/Re2c)

php_re2c(
  php_ext_pdo_sqlite_sql_parser
  sqlite_sql_parser.re
  ${CMAKE_CURRENT_SOURCE_DIR}/sqlite_sql_parser.c
  ADD_DEFAULT_OPTIONS
  CODEGEN
)
