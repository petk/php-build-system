# Generate lexer.

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()

include(PHP/RE2C)

php_re2c(
  php_ext_phar_path_check
  phar_path_check.re
  ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c
  OPTIONS -b
  CODEGEN
)
