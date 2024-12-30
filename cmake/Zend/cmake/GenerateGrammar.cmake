# Generate lexer and parser files.

include(FeatureSummary)
include(PHP/Package/BISON)
include(PHP/Package/RE2C)

if(
  NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.h
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.h
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
    zend_ini_parser
    zend_ini_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_parser.c
    HEADER
    ${verbose}
  )

  if(CMAKE_SCRIPT_MODE_FILE)
    set(verbose "")
  else()
    set(verbose VERBOSE)
  endif()

  bison(
    zend_language_parser
    zend_language_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_parser.c
    HEADER
    ${verbose}
    CODEGEN
  )

  # Tweak zendparse to be exported through ZEND_API. This has to be revisited
  # once bison supports foreign skeletons and that bison version is used. Read
  # https://git.savannah.gnu.org/cgit/bison.git/tree/data/README.md for more.
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

    # Run patch based on whether building or running inside a CMake script.
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
endif()

if(
  NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c
  OR NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h
)
  set_package_properties(RE2C PROPERTIES TYPE REQUIRED)
endif()

if(RE2C_FOUND)
  re2c(
    zend_ini_scanner
    zend_ini_scanner.l
    ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner.c
    HEADER ${CMAKE_CURRENT_SOURCE_DIR}/zend_ini_scanner_defs.h
    OPTIONS --case-inverted -cbdF
    CODEGEN
  )

  re2c(
    zend_language_scanner
    zend_language_scanner.l
    ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner.c
    HEADER ${CMAKE_CURRENT_SOURCE_DIR}/zend_language_scanner_defs.h
    OPTIONS --case-inverted -cbdF
    CODEGEN
  )
endif()
