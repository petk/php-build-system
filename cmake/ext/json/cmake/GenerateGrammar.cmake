# Generate lexer and parser files.

include(FeatureSummary)
include(PHP/Package/BISON)
include(PHP/Package/RE2C)

if(
  NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.h
)
  set_package_properties(BISON PROPERTIES TYPE REQUIRED)
endif()

if(BISON_FOUND)
  if(CMAKE_SCRIPT_MODE_FILE)
    set(verbose "")
  else()
    set(verbose VERBOSE) #REPORT_FILE json_parser.output)
  endif()

  bison(
    php_ext_json_parser
    json_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/json_parser.tab.c
    ${verbose}
    HEADER
    CODEGEN
  )
endif()

if(
  NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/json_scanner.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/php_json_scanner_defs.h
)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

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
