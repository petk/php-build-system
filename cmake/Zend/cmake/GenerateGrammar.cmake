# Generate parser and lexer files.

if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  message(FATAL_ERROR "This file should be used with include().")
endif()

include(PHP/Bison)

if(CMAKE_SCRIPT_MODE_FILE)
  set(verbose "")
else()
  set(verbose VERBOSE)
endif()

php_bison(
  zend_ini_parser
  zend_ini_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c
  HEADER
  ADD_DEFAULT_OPTIONS
  ${verbose}
  CODEGEN
)

php_bison(
  zend_language_parser
  zend_language_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c
  HEADER
  ADD_DEFAULT_OPTIONS
  ${verbose}
  CODEGEN
)

# Tweak zendparse to be exported through ZEND_API. This has to be revisited if
# Bison will support foreign skeletons.
# See: https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md
block()
  string(
    CONCAT patch
    "cmake_path(SET SOURCE_DIR NORMALIZE ${CMAKE_CURRENT_SOURCE_DIR})\n"
    [[
    cmake_path(
      RELATIVE_PATH
      SOURCE_DIR
      BASE_DIRECTORY ${CMAKE_SOURCE_DIR}
      OUTPUT_VARIABLE relativeDir
    )
    file(READ "${SOURCE_DIR}/zend_language_parser.h" content)
    string(
      REPLACE
      "int zendparse"
      "ZEND_API int zendparse"
      content_2
      "${content}"
    )
    if(
      NOT content MATCHES "ZEND_API int zendparse"
      AND NOT content STREQUAL "${content_2}"
    )
      message(STATUS "Patching ${relativeDir}/zend_language_parser.h")
      file(WRITE "${SOURCE_DIR}/zend_language_parser.h" "${content_2}")
    endif()

    file(READ "${SOURCE_DIR}/zend_language_parser.c" content)
    string(
      REPLACE
      "int zendparse"
      "ZEND_API int zendparse"
      content_2
      "${content}"
    )
    if(
      NOT content MATCHES "ZEND_API int zendparse"
      AND NOT content STREQUAL "${content_2}"
    )
      message(STATUS "Patching ${relativeDir}/zend_language_parser.c")
      file(WRITE "${SOURCE_DIR}/zend_language_parser.c" "${content_2}")
    endif()
  ]])

  # Run patch based on whether building or running inside a script.
  if(CMAKE_SCRIPT_MODE_FILE)
    cmake_language(EVAL CODE "${patch}")
  else()
    file(
      GENERATE
      OUTPUT CMakeFiles/Zend/PatchLanguageParser.cmake
      CONTENT "${patch}"
    )
    add_custom_target(
      zend_language_parser_patch
      COMMAND ${CMAKE_COMMAND} -P CMakeFiles/Zend/PatchLanguageParser.cmake
      DEPENDS zend_language_parser
      VERBATIM
    )
    add_dependencies(zend zend_language_parser_patch)
  endif()
endblock()

include(PHP/Re2c)

php_re2c(
  zend_ini_scanner
  zend_ini_scanner.l
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h
  ADD_DEFAULT_OPTIONS
  OPTIONS
    --bit-vectors
    --case-inverted
    --conditions
    --debug-output
    --flex-syntax
  CODEGEN
)

php_re2c(
  zend_language_scanner
  zend_language_scanner.l
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h
  ADD_DEFAULT_OPTIONS
  OPTIONS
    --bit-vectors
    --case-inverted
    --conditions
    --debug-output
    --flex-syntax
  CODEGEN
)
