# Generate lexer and parser files.

if(PHP_SOURCE_DIR)
  set(workingDirectory ${PHP_SOURCE_DIR})
else()
  set(workingDirectory ${CMAKE_CURRENT_SOURCE_DIR})
endif()

# Generate parser files.
if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.h
)
  set(PHP_BISON_OPTIONAL TRUE)
endif()
include(PHP/BISON)

if(BISON_FOUND)
  if(CMAKE_SCRIPT_MODE_FILE)
    set(verbose "")
  else()
    set(verbose VERBOSE REPORT_FILE phpdbg_parser.output)
  endif()

  bison(
    php_sapi_phpdbg_parser
    phpdbg_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
    HEADER
    #HEADER_FILE phpdbg_parser.h
    ${verbose}
    WORKING_DIRECTORY ${workingDirectory}
  )
endif()

# Generate lexer files.
if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
  AND NOT CMAKE_SCRIPT_MODE_FILE
)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()
include(PHP/RE2C)

if(RE2C_FOUND)
  re2c(
    php_sapi_phpdbg_lexer
    phpdbg_lexer.l
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
    OPTIONS -cbdF
    CODEGEN
    WORKING_DIRECTORY ${workingDirectory}
  )
endif()
