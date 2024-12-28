# Generate lexer files.

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c
)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()

include(PHP/RE2C)

if(RE2C_FOUND)
  re2c(
    php_ext_standard_url_scanner_ex
    url_scanner_ex.re
    ${CMAKE_CURRENT_SOURCE_DIR}/url_scanner_ex.c
    OPTIONS -b
    CODEGEN
  )

  re2c(
    php_ext_standard_var_unserializer
    var_unserializer.re
    ${CMAKE_CURRENT_SOURCE_DIR}/var_unserializer.c
    OPTIONS -b
    CODEGEN
  )
endif()
