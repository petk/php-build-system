#[=============================================================================[
# PHP/PkgConfigGenerator

Generate pkg-config .pc file.

CMake at the time of writing doesn't provide a solution to generate pkg-config
pc files with getting clean linked libraries retrieved from the targets:
https://gitlab.kitware.com/cmake/cmake/-/issues/22621

Also there is a common issue with installation prefix not being applied when
using `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

The following function is exposed:

```cmake
pkgconfig_generate_pc(
  <pc-template-file>
  <pc-file-output>
  TARGET <target>
  [VARIABLES <variable> <value> ...]
)
```

Generate pkg-config `<pc-file-output>` from the given pc `<pc-template-file>`
template.

* `TARGET`
  Name of the target for getting libraries.
* `VARIABLES`
  Pairs of variable names and values. Variable values support generator
  expressions. For example:

  ```cmake
  pkgconfig_generate_pc(
    ...
    VARIABLES
      debug "$<IF:$<CONFIG:Debug>,yes,no>"
      variable "$<IF:$<BOOL:${VARIABLE}>,yes,no>"
  )
  ```

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.
#]=============================================================================]

include_guard(GLOBAL)

find_program(
  PKGCONFIG_OBJDUMP_EXECUTABLE
  NAMES objdump
  DOC "Path to the objdump executable"
)
mark_as_advanced(PKGCONFIG_OBJDUMP_EXECUTABLE)

# Parse given variables and create a list of options or variables for passing to
# add_custom_command and configure_file().
function(_pkgconfig_parse_variables variables)
  # Check for even number of keyword values.
  list(LENGTH variables length)
  math(EXPR modulus "${length} % 2")
  if(NOT modulus EQUAL 0)
    message(
      FATAL_ERROR
      "The keyword VARIABLES must be a list of pairs - variable-name and value "
      "(it must contain an even number of items)."
    )
  endif()

  set(isValue FALSE)
  set(variablesOptions "")
  set(resultVariables "")
  set(resultValues "")
  foreach(variable IN LISTS variables)
    if(isValue)
      set(isValue FALSE)
      continue()
    endif()
    list(POP_FRONT variables var value)

    list(APPEND resultVariables ${var})

    # The resultValues are for the install(CODE) and generator expression
    # $<INSTALL_PREFIX> works since CMake 3.27, for earlier versions the escaped
    # variable CMAKE_INSTALL_PREFIX can be used.
    if(
      CMAKE_VERSION VERSION_LESS 3.27
      AND value MATCHES [[.*\$<INSTALL_PREFIX>.*]]
    )
      string(
        REPLACE
        "$<INSTALL_PREFIX>"
        "\${CMAKE_INSTALL_PREFIX}"
        replacedValue
        "${value}"
      )
      list(APPEND resultValues "${replacedValue}")
    else()
      list(APPEND resultValues "${value}")
    endif()

    # Replace possible INSTALL_PREFIX in value for usage in add_custom_command,
    # in the resultValues above the intact genex is left for enabling the
    # possible 'cmake --install --prefix ...' override.
    if(value MATCHES [[.*\$<INSTALL_PREFIX>.*]])
      string(
        REPLACE
        "$<INSTALL_PREFIX>"
        "${CMAKE_INSTALL_PREFIX}"
        value
        "${value}"
      )
    endif()

    list(APPEND variablesOptions -D ${var}="${value}")

    set(isValue TRUE)
  endforeach()

  set(variablesOptions "${variablesOptions}" PARENT_SCOPE)
  set(resultVariables "${resultVariables}" PARENT_SCOPE)
  set(resultValues "${resultValues}" PARENT_SCOPE)
endfunction()

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
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_TARGET AND NOT TARGET ${parsed_TARGET})
    message(FATAL_ERROR "${parsed_TARGET} is not a target.")
  endif()

  if(NOT ARGV0)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION} expects a template file name."
    )
  endif()

  if(NOT ARGV1)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION} expects an output file name."
    )
  endif()

  set(template "${ARGV0}")
  if(NOT IS_ABSOLUTE "${template}")
    cmake_path(
      ABSOLUTE_PATH
      template
      BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      NORMALIZE
    )
  endif()

  set(output "${ARGV1}")
  if(NOT IS_ABSOLUTE "${output}")
    cmake_path(
      ABSOLUTE_PATH
      output
      BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      NORMALIZE
    )
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
        foreach(item IN LISTS content)
          if(IS_ABSOLUTE "${item}")
            list(APPEND libs "${item}")
          elseif(item MATCHES "^-l")
            list(APPEND libs "${item}")
          endif()
        endforeach()
        list(REMOVE_DUPLICATES libs)
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
        foreach(library IN LISTS matches)
          if(library MATCHES [[NEEDED[ ]+(.+)]])
            string(STRIP "${CMAKE_MATCH_1}" library)
            string(REGEX REPLACE "^lib(.*).so.*" [[\1]] library "${library}")
            if(NOT library MATCHES "c|root")
              list(APPEND libraries "-l${library}")
            endif()
          endif()
        endforeach()
      endif()

      list(JOIN libraries " " PHP_LIBS_PRIVATE)
      configure_file(${TEMPLATE} ${OUTPUT} @ONLY)
    ]=]
  )

  if(parsed_TARGET)
    set(targetOption -D TARGET_FILE="$<TARGET_FILE:${parsed_TARGET}>")
  endif()

  if(parsed_VARIABLES)
    _pkgconfig_parse_variables("${parsed_VARIABLES}")
  endif()

  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE outputRelativePath
  )

  string(MAKE_C_IDENTIFIER "${outputRelativePath}" targetName)

  add_custom_target(
    pkgconfig_${targetName}
    ALL
    COMMAND ${CMAKE_COMMAND}
      -D PKGCONFIG_OBJDUMP_EXECUTABLE=${PKGCONFIG_OBJDUMP_EXECUTABLE}
      -D TEMPLATE=${template}
      -D OUTPUT=${output}
      ${targetOption}
      ${variablesOptions}
      -P CMakeFiles/PkgConfigGeneratePc.cmake
    COMMENT "[PkgConfig] Generating ${outputRelativePath}"
  )

  install(CODE "
    block()
      set(resultVariables ${resultVariables})
      set(resultValues \"${resultValues}\")

      foreach(var value IN ZIP_LISTS resultVariables resultValues)
        set(\${var} \"\${value}\")
      endforeach()

      configure_file(
        ${template}
        ${output}
        @ONLY
      )
    endblock()
  ")
endfunction()
