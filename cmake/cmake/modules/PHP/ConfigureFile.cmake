#[=============================================================================[
Wrapper built on top of CMake's configure_file().

There is a common issue with installation prefix not being applied when using
`--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

The following function is exposed:

```cmake
php_configure_file(
  <template-file>
  <file-output>
  [INSTALL_DESTINATION <path>]
  [VARIABLES [<variable> <value>] ...]
)
```

* `INSTALL_DESTINATION`
  Path to the directory where the generated file `<file-output>` will be
  installed to. If not provided, `<file-output>` will not be installed.
* `VARIABLES`
  Pairs of variable names and values.

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.
#]=============================================================================]

include_guard(GLOBAL)

# Parse given variables and create a list of options or variables for passing to
# configure_file().
function(_php_configure_file_parse_variables variables)
  # Check for even number of keyword values.
  list(LENGTH variables length)
  math(EXPR modulus "${length} % 2")
  if(NOT modulus EQUAL 0)
    message(
      FATAL_ERROR
      "The keyword VARIABLES must be a list of pairs - variable-name and "
      "value (it must contain an even number of items)."
    )
  endif()

  set(is_value FALSE)
  set(result_variables "")
  set(result_values "")
  foreach(variable IN LISTS variables)
    if(is_value)
      set(is_value FALSE)
      continue()
    endif()
    list(POP_FRONT variables var value)

    list(APPEND result_variables ${var})

    # The result_values are for the install(CODE) and generator expression
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
        replaced_value
        "${value}"
      )
      list(APPEND result_values "${replaced_value}")
    else()
      list(APPEND result_values "${value}")
    endif()

    set(is_value TRUE)
  endforeach()

  set(result_variables "${result_variables}" PARENT_SCOPE)
  set(result_values "${result_values}" PARENT_SCOPE)
endfunction()

function(php_configure_file)
  cmake_parse_arguments(
    PARSE_ARGV
    2
    parsed                # prefix
    ""                    # options
    "INSTALL_DESTINATION" # one-value keywords
    "VARIABLES"           # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "php_configure_file expects a template file name")
  endif()

  if(NOT ARGV1)
    message(FATAL_ERROR "php_configure_file expects an output file name")
  endif()

  set(template "${ARGV0}")
  if(NOT IS_ABSOLUTE "${template}")
    set(template "${CMAKE_CURRENT_SOURCE_DIR}/${template}")
  endif()

  set(output "${ARGV1}")
  if(NOT IS_ABSOLUTE "${output}")
    set(output "${CMAKE_CURRENT_BINARY_DIR}/${output}")
  endif()

  if(parsed_VARIABLES)
    _php_configure_file_parse_variables("${parsed_VARIABLES}")
  endif()

  cmake_path(GET template FILENAME filename)

  configure_file(
    ${template}
    ${output}
    @ONLY
  )

  cmake_path(GET output FILENAME output_file)

  install(CODE "
    block()
      set(result_variables ${result_variables})
      set(result_values \"${result_values}\")

      foreach(var value IN ZIP_LISTS result_variables result_values)
        set(\${var} \"\${value}\")
      endforeach()

      configure_file(
        ${template}
        ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${output_file}
        @ONLY
      )
    endblock()
  ")

  if(parsed_INSTALL_DESTINATION)
    install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${output_file}
      DESTINATION ${parsed_INSTALL_DESTINATION}
    )
  endif()
endfunction()
