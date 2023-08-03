#[=============================================================================[
CMake re2c module to find and use free and open-source lexer generator re2c.
https://re2c.org/

The module defines the following variables

``RE2C_EXECUTABLE``
  path to the ``re2c`` program

``RE2C_VERSION``
  version of ``re2c``

``RE2C_FOUND``
  "True" if the program was found

The minimum required version of ``re2c`` can be specified using the standard
CMake syntax, e.g. :command:`find_package(RE2C 0.15.3)`.

If ``re2c`` is found, the module defines the macro::

  re2c_target(NAME <name> INPUT <input> OUTPUT <output>
              [OPTIONS <options>]
  )

#]=============================================================================]

find_program(RE2C_EXECUTABLE re2c DOC "path to the re2c executable")
mark_as_advanced(RE2C_EXECUTABLE)

if(NOT RE2C_EXECUTABLE)
  message(FATAL_ERROR "re2c not found. Please install re2c.")
endif()

execute_process(COMMAND ${RE2C_EXECUTABLE} --vernum OUTPUT_VARIABLE RE2C_VERSION_RAW OUTPUT_STRIP_TRAILING_WHITESPACE)

math(EXPR RE2C_VERSION_MAJOR "${RE2C_VERSION_RAW} / 10000")
math(EXPR RE2C_VERSION_MINOR "(${RE2C_VERSION_RAW} - ${RE2C_VERSION_MAJOR} * 10000) / 100")
math(EXPR RE2C_VERSION_PATCH "${RE2C_VERSION_RAW} - ${RE2C_VERSION_MAJOR} * 10000 - ${RE2C_VERSION_MINOR} * 100")
set(RE2C_VERSION "${RE2C_VERSION_MAJOR}.${RE2C_VERSION_MINOR}.${RE2C_VERSION_PATCH}")

macro(re2c_target)
  cmake_parse_arguments(PARSED_ARGS "" "NAME;INPUT;OUTPUT;OPTIONS" "DEPENDS" ${ARGN})

  if(NOT PARSED_ARGS_OUTPUT)
    message(FATAL_ERROR "re2c_target expects an output filename")
  endif()

  if(NOT PARSED_ARGS_INPUT)
    message(FATAL_ERROR "re2c_target expects an input filename")
  endif()

  if(NOT PARSED_ARGS_NAME)
    message(FATAL_ERROR "re2c_target expects a target name")
  endif()

  set(re2c_target_cmdopt "")
  set(re2c_target_extraopts "${PARSED_ARGS_OPTIONS}")
  separate_arguments(re2c_target_extraopts)
  list(APPEND re2c_target_cmdopt ${re2c_target_extraopts})

  add_custom_command(
    OUTPUT ${PARSED_ARGS_OUTPUT}
    COMMAND ${RE2C_EXECUTABLE} ${re2c_target_cmdopt} -o ${PARSED_ARGS_OUTPUT} ${PARSED_ARGS_INPUT}
    DEPENDS ${PARSED_ARGS_INPUT} ${PARSED_ARGS_DEPENDS}
    COMMENT "[RE2C][${PARSED_ARGS_NAME}] Building lexer with re2c ${RE2C_VERSION}"
  )

  add_custom_target(
    ${PARSED_ARGS_NAME}
    SOURCES ${PARSED_ARGS_INPUT}
    DEPENDS ${PARSED_ARGS_OUTPUT}
  )
endmacro()