#[=============================================================================[
Wrapper built on top of CMake's `configure_file()`.

There is a common issue with installation prefix not being applied when using
the `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

The following function is exposed:

```cmake
php_configure_file(
  <template-file>
  <output-file>
  [VARIABLES [<variable> <value>] ...]
)
```

* `VARIABLES`

  Pairs of variable names and values. Variable values support generator
  expressions.

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.
#]=============================================================================]

include_guard(GLOBAL)

# Parse given variables and create variables and values lists for passing to the
# configure_file().
#   _php_configure_file_parse_variables(
#     variableValuePairs
#     VARIABLES <variable-name>
#     VALUES <values-variable-name>
#     VALUES_IN_CODE <code-values-variable-name>
#   )
function(_php_configure_file_parse_variables)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed                            # prefix
    ""                                # options
    ""                                # one-value keywords
    "VARIABLES;VALUES;VALUES_IN_CODE" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGV0)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION} expects 1st argument"
    )
  endif()

  foreach(item VARIABLES VALUES VALUES_IN_CODE)
    if(NOT parsed_${item})
      message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: missing keyword ${item}")
    endif()
  endforeach()

  # Replace possible semicolons with a generator expression.
  set(processedItems)
  foreach(item IN LISTS ARGV0)
    if(item MATCHES [[.*\;.*]])
      string(
        REPLACE
        ";"
        "$<SEMICOLON>"
        item
        "${item}"
      )
    endif()
    list(APPEND processedItems "${item}")
  endforeach()

  set(isValue FALSE)
  set(resultVariables "")
  set(resultValues "")
  set(resultValuesInCode "")

  foreach(item IN LISTS processedItems)
    if(isValue)
      set(isValue FALSE)
      continue()
    endif()
    set(isValue TRUE)

    list(POP_FRONT processedItems var value)
    list(APPEND resultVariables ${var})

    # The resultValues are for the first configure_file().
    if(value MATCHES [[.*\$<INSTALL_PREFIX>.*]])
      string(
        REPLACE
        "$<INSTALL_PREFIX>"
        "${CMAKE_INSTALL_PREFIX}"
        replaced
        "${value}"
      )
      list(APPEND resultValues "${replaced}")
    else()
      list(APPEND resultValues "${value}")
    endif()

    # The resultValuesInCode are for the configure_file inside the install(CODE)
    # and generator expression $<INSTALL_PREFIX> works since CMake 3.27. For
    # earlier versions the escaped variable CMAKE_INSTALL_PREFIX can be used.
    if(
      CMAKE_VERSION VERSION_LESS 3.27
      AND value MATCHES [[.*\$<INSTALL_PREFIX>.*]]
    )
      string(
        REPLACE
        "$<INSTALL_PREFIX>"
        "\${CMAKE_INSTALL_PREFIX}"
        replaced
        "${value}"
      )
      list(APPEND resultValuesInCode "${replaced}")
    else()
      list(APPEND resultValuesInCode "${value}")
    endif()
  endforeach()

  set(${parsed_VARIABLES} "${resultVariables}" PARENT_SCOPE)
  set(${parsed_VALUES} "${resultValues}" PARENT_SCOPE)
  set(${parsed_VALUES_IN_CODE} "${resultValuesInCode}" PARENT_SCOPE)
endfunction()

function(php_configure_file)
  cmake_parse_arguments(
    PARSE_ARGV
    2
    parsed      # prefix
    ""          # options
    ""          # one-value keywords
    "VARIABLES" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects a template filename")
  endif()

  if(NOT ARGV1)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects an output filename")
  endif()

  # Check for even number of keyword values.
  list(LENGTH parsed_VARIABLES length)
  math(EXPR modulus "${length} % 2")
  if(NOT modulus EQUAL 0)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION}: The keyword VARIABLES must be a list of "
      "variable-name and value pairs (it must contain an even number of items)."
    )
  endif()

  set(___phpConfigureFileTemplate "${ARGV0}")
  if(NOT IS_ABSOLUTE "${___phpConfigureFileTemplate}")
    set(
      ___phpConfigureFileTemplate
      "${CMAKE_CURRENT_SOURCE_DIR}/${___phpConfigureFileTemplate}"
    )
  endif()

  set(___phpConfigureFileOutput "${ARGV1}")
  if(NOT IS_ABSOLUTE "${___phpConfigureFileOutput}")
    set(
      ___phpConfigureFileOutput
      "${CMAKE_CURRENT_BINARY_DIR}/${___phpConfigureFileOutput}"
    )
  endif()

  cmake_path(GET ___phpConfigureFileOutput FILENAME filename)
  set(
    ___phpConfigureFileOutputTemporary
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/__phpConfigureFile_${filename}.cmake.in
  )

  if(parsed_VARIABLES)
    _php_configure_file_parse_variables(
      "${parsed_VARIABLES}"
      VARIABLES variables
      VALUES values
      VALUES_IN_CODE valuesInCode
    )
  endif()

  block()
    foreach(var value IN ZIP_LISTS variables values)
      set(${var} "${value}")
    endforeach()

    configure_file(
      ${___phpConfigureFileTemplate}
      ${___phpConfigureFileOutputTemporary}
      @ONLY
    )

    # To be able to evaluate possible additional generator expressions.
    file(
      GENERATE
      # TODO: Multi-config generators need to write separate files.
      #OUTPUT $<CONFIG>/file.output
      OUTPUT ${___phpConfigureFileOutput}
      INPUT ${___phpConfigureFileOutputTemporary}
    )
  endblock()

  install(CODE "
    block()
      set(variables ${variables})
      set(valuesInCode \"${valuesInCode}\")

      foreach(var value IN ZIP_LISTS variables valuesInCode)
        set(\${var} \"\${value}\")
      endforeach()

      configure_file(
        ${___phpConfigureFileTemplate}
        ${___phpConfigureFileOutput}
        @ONLY
      )
    endblock()
  ")
endfunction()
