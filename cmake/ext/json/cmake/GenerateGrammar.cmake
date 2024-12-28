# Generate lexer and parser files.

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
)
  set(PHP_BISON_OPTIONAL TRUE)
endif()

include(PHP/BISON)

if(BISON_FOUND)
  if(CMAKE_SCRIPT_MODE_FILE)
    set(verbose "")
  else()
    set(verbose VERBOSE REPORT_FILE json_parser.output)
  endif()

  bison(
    php_ext_json_parser
    json_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
    ${verbose}
    HEADER
    #HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
  )
endif()

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()

include(PHP/RE2C)

if(RE2C_FOUND)
  re2c(
    php_ext_json_scanner
    json_scanner.re
    ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
    HEADER ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
    OPTIONS -bc
    CODEGEN
  )
endif()
