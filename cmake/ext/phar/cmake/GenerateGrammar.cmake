# Generate lexer files.

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  message(FATAL_ERROR "This file should be used with include().")
endif()

include(PHP/Re2c)

php_re2c(
  php_ext_phar_path_check
  phar_path_check.re
  ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c
  ADD_DEFAULT_OPTIONS
  OPTIONS --bit-vectors
  CODEGEN
)
