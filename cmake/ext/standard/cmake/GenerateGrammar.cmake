# Generate lexer files.

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  message(FATAL_ERROR "This file should be used with include().")
endif()

include(PHP/Re2c)

php_re2c(
  php_ext_standard_url_scanner_ex
  url_scanner_ex.re
  ${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c
  ADD_DEFAULT_OPTIONS
  OPTIONS --bit-vectors
  CODEGEN
)

php_re2c(
  php_ext_standard_var_unserializer
  var_unserializer.re
  ${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c
  ADD_DEFAULT_OPTIONS
  OPTIONS --bit-vectors
  CODEGEN
)
