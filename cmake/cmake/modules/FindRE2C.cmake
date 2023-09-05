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

include(CheckCSourceCompiles)
include(FindPackageHandleStandardArgs)

find_program(RE2C_EXECUTABLE re2c DOC "path to the re2c executable")
mark_as_advanced(RE2C_EXECUTABLE)

if(RE2C_EXECUTABLE)
  execute_process(COMMAND ${RE2C_EXECUTABLE} --vernum OUTPUT_VARIABLE RE2C_VERSION_RAW OUTPUT_STRIP_TRAILING_WHITESPACE)

  math(EXPR RE2C_VERSION_MAJOR "${RE2C_VERSION_RAW} / 10000")
  math(EXPR RE2C_VERSION_MINOR "(${RE2C_VERSION_RAW} - ${RE2C_VERSION_MAJOR} * 10000) / 100")
  math(EXPR RE2C_VERSION_PATCH "${RE2C_VERSION_RAW} - ${RE2C_VERSION_MAJOR} * 10000 - ${RE2C_VERSION_MINOR} * 100")
  set(RE2C_VERSION "${RE2C_VERSION_MAJOR}.${RE2C_VERSION_MINOR}.${RE2C_VERSION_PATCH}")
endif()

find_package_handle_standard_args(
  RE2C
  REQUIRED_VARS RE2C_EXECUTABLE RE2C_VERSION
  VERSION_VAR RE2C_VERSION
  REASON_FAILURE_MESSAGE "re2c not found. Please install re2c."
)

# Check for re2c -g flag.
if(PHP_RE2C_CGOTO)
  message(STATUS "Checking whether re2c -g works")
  check_c_source_compiles("
    int main(int argc, const char **argv) {
      argc = argc;
      argv = argv;
    label1:
    label2:
      static void *adr[] = { &&label1, &&label2};
      goto *adr[0];
      return 0;
    }
  " HAVE_RE2C_CGOTO)

  if(HAVE_RE2C_CGOTO)
    message(STATUS "Adding flag -g to re2c for using computed goto gcc extension")
    set(RE2C_FLAGS "-g" CACHE INTERNAL "Whether to use computed goto gcc extension with re2c")
  endif()
endif()

function(re2c_target)
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

  separate_arguments(re2c_target_extraopts NATIVE_COMMAND "${PARSED_ARGS_OPTIONS}")
  list(APPEND re2c_target_cmdopt ${re2c_target_extraopts})
  list(APPEND re2c_target_cmdopt ${RE2C_FLAGS})

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
    COMMENT "[RE2C] Building lexer with re2c ${RE2C_VERSION}"
  )
endfunction()
