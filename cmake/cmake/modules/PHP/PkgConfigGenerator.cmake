#[=============================================================================[
Generate pkgconfig .pc file.

CMake at the time of writing doesn't provide a solution to generate pkgconfig
pc files with getting clean linked libraries retrieved from the targets:
https://gitlab.kitware.com/cmake/cmake/-/issues/22621

Also there is a common issue with installation prefix not being applied when
using --prefix command line option at the installation phase:
  cmake --install <build-dir> --prefix <prefix>

TODO: This module will be refactored and changed further in the future.

The following function is exposed:

pkgconfig_generate_pc(
  <pc-template-file>
  <pc-file-output>
  TARGET <target>
  [VARIABLES [<variable> <value>]...]
)

  Generate pkgconfig <pc-file-output> from the given pc <pc-template-file>
  template.

  TARGET
    Name of the target for getting libraries.
  VARIABLES
    Pairs of variable names and values.
]=============================================================================]#

include_guard(GLOBAL)

find_program(
  PKGCONFIG_OBJDUMP_EXECUTABLE
  NAMES objdump
  DOC "Path to the objdump executable"
)
mark_as_advanced(PKGCONFIG_OBJDUMP_EXECUTABLE)

function(pkgconfig_generate_pc)
  cmake_parse_arguments(
    PARSE_ARGV
    2
    parsed      # prefix
    ""          # options
    "TARGET"    # one-value keywords
    "VARIABLES" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_TARGET AND NOT TARGET ${parsed_TARGET})
    message(FATAL_ERROR "${parsed_TARGET} is not a target")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "pkgconfig_generate_pc expects a template file name")
  endif()

  if(NOT ARGV1)
    message(FATAL_ERROR "pkgconfig_generate_pc expects an output file name")
  endif()

  set(template "${ARGV0}")
  if(NOT IS_ABSOLUTE "${template}")
    set(template "${CMAKE_CURRENT_SOURCE_DIR}/${template}")
  endif()

  set(output "${ARGV1}")
  if(NOT IS_ABSOLUTE "${output}")
    set(output "${CMAKE_CURRENT_BINARY_DIR}/${output}")
  endif()

  file(
    GENERATE
    OUTPUT CMakeFiles/PkgConfigGeneratePc.cmake
    CONTENT [=[
      # TODO: Recheck this type of implementation.
      if(LINK_TXT)
        file(STRINGS ${LINK_TXT} content LIMIT_COUNT 1)
        string(REGEX REPLACE "^.*-o php " "" content "${content}")
        string(REPLACE " " ";" content "${content}")
        set(libs "")
        foreach(item ${content})
          if(IS_ABSOLUTE "${item}")
            list(APPEND libs "${item}")
          elseif(item MATCHES "^-l")
            list(APPEND libs "${item}")
          endif()
        endforeach()
        list(REMOVE_DUPLICATES libs)
        message(STATUS "Libs from link.txt: ${libs}")
      endif()

      if(PKGCONFIG_OBJDUMP_EXECUTABLE)
        execute_process(
          COMMAND objdump -p ${TARGET_FILE}
          OUTPUT_VARIABLE result
          OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_QUIET
        )
        string(REGEX MATCHALL [[NEEDED[ ]+[A-Za-z0-9.]+]] matches "${result}")
        set(libraries "")
        foreach(library ${matches})
          if(library MATCHES [[NEEDED[ ]+(.+)]])
            string(STRIP "${CMAKE_MATCH_1}" library)
            string(REGEX REPLACE "^lib(.*).so.*" [[\1]] library "${library}")
            if(NOT library MATCHES "c|root")
              list(APPEND libraries "-l${library}")
            endif()
          endif()
        endforeach()

        message(STATUS "Libraries from objdump: ${libraries}")
      endif()

      list(JOIN libraries " " PHP_LIBS_PRIVATE)
      configure_file(${TEMPLATE} ${OUTPUT} @ONLY)
    ]=]
  )

  if(parsed_TARGET)
    set(target_option -D TARGET_FILE="$<TARGET_FILE:${parsed_TARGET}>")
  endif()

  if(parsed_VARIABLES)
    set(is_value FALSE)

    set(variables ${parsed_VARIABLES})
    set(variables_options "")
    foreach(variable ${parsed_VARIABLES})
      if(is_value)
        set(is_value FALSE)
        continue()
      endif()
      list(POP_FRONT variables var value)
      list(APPEND variables_options -D ${var}="${value}")
      set(is_value TRUE)
    endforeach()
  endif()

  cmake_path(GET template FILENAME filename)

  string(MAKE_C_IDENTIFIER "${filename}" target_name)

  add_custom_target(
    pkgconfig_generate_${target_name}
    ALL
    COMMAND ${CMAKE_COMMAND}
      -D PKGCONFIG_OBJDUMP_EXECUTABLE=${PKGCONFIG_OBJDUMP_EXECUTABLE}
      -D TEMPLATE=${template}
      -D OUTPUT=${output}
      ${target_option}
      ${variables_options}
      -P CMakeFiles/PkgConfigGeneratePc.cmake
    COMMENT "[PkgConfig] Generating pkg-config ${filename} file"
  )
endfunction()
