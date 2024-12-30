# Generate lexer and parser files.

include(FeatureSummary)
include(PHP/Package/BISON)
include(PHP/Package/RE2C)

if(
  NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.h
)
  set_package_properties(BISON PROPERTIES TYPE REQUIRED)
endif()

if(BISON_FOUND)
  if(CMAKE_SCRIPT_MODE_FILE)
    set(verbose "")
  else()
    set(verbose VERBOSE)
  endif()

  bison(
    php_sapi_phpdbg_parser
    phpdbg_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
    HEADER
    ${verbose}
    CODEGEN
  )
endif()

if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

if(RE2C_FOUND)
  re2c(
    php_sapi_phpdbg_lexer
    phpdbg_lexer.l
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
    OPTIONS
      --conditions
      --debug-output
      --bit-vectors
      --flex-syntax
    CODEGEN
  )
endif()
