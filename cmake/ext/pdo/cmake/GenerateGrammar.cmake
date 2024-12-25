# Generate lexer.

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()

include(PHP/RE2C)

php_re2c(
  php_ext_pdo_sql_parser
  pdo_sql_parser.re
  ${CMAKE_CURRENT_SOURCE_DIR}/pdo_sql_parser.c
  CODEGEN
)
