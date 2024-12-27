# Generate lexer and parser files.

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h
)
  set(PHP_BISON_OPTIONAL TRUE)
endif()
include(PHP/BISON)

php_bison(
  zend_ini_parser
  zend_ini_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c
  COMPILE_FLAGS "${PHP_BISON_DEFAULT_OPTIONS}"
  VERBOSE REPORT_FILE zend_ini_parser.output
  DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h
)

php_bison(
  zend_language_parser
  zend_language_parser.y
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c
  COMPILE_FLAGS "${PHP_BISON_DEFAULT_OPTIONS}"
  VERBOSE REPORT_FILE zend_language_parser.output
  DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h
)

# Tweak zendparse to be exported through ZEND_API. This has to be revisited
# once bison supports foreign skeletons and that bison version is used. Read
# https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md for more.
block()
  string(
    CONCAT patch
    "set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})\n"
    [[
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
      message(STATUS "[Zend] Patching zend_language_parser.h")
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
      message(STATUS "[Zend] Patching zend_language_parser.c")
      file(WRITE "${SOURCE_DIR}/zend_language_parser.c" "${content_2}")
    endif()
  ]])

  # Run patch based on whether building or running inside a CMake script.
  if(CMAKE_SCRIPT_MODE_FILE)
    cmake_language(EVAL CODE "${patch}")
  else()
    file(
      GENERATE
      OUTPUT CMakeFiles/PatchLanguageParser.cmake
      CONTENT "${patch}"
    )
    add_custom_target(
      zend_patch_language_parser
      COMMAND ${CMAKE_COMMAND} -P CMakeFiles/PatchLanguageParser.cmake
      DEPENDS ${BISON_zend_language_parser_OUTPUTS}
      VERBATIM
    )
    add_dependencies(zend zend_patch_language_parser)
  endif()
endblock()

if(
  EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c
  AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h
)
  set(PHP_RE2C_OPTIONAL TRUE)
endif()
include(PHP/RE2C)

php_re2c(
  zend_ini_scanner
  zend_ini_scanner.l
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h
  OPTIONS --case-inverted -cbdF
  CODEGEN
)

php_re2c(
  zend_language_scanner
  zend_language_scanner.l
  ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c
  HEADER ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h
  OPTIONS --case-inverted -cbdF
  CODEGEN
)
