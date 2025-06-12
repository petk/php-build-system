#[=============================================================================[
# PHP/PkgConfig

Generate pkg-config .pc file.

CMake at the time of writing doesn't provide an out-of-the-box solution to
generate pkg-config pc files with required libraries to link retrieved from the
targets:
https://gitlab.kitware.com/cmake/cmake/-/issues/22621

Once pkg-config integration is added in CMake natively, this module will be
replaced.

Also there is a common issue with installation prefix not being applied when
using `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

This module provides the following function:

```cmake
php_pkgconfig_generate_pc(
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
  php_pkgconfig_generate_pc(
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

## Usage

```cmake
# CMakeLists.txt
include(PHP/PkgConfig)
```
#]=============================================================================]

include_guard(GLOBAL)

# Parse given variables and create a list of options or variables for passing to
# add_custom_command and configure_file().
function(_php_pkgconfig_parse_variables variables)
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
    list(APPEND resultValues "${value}")

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

function(php_pkgconfig_generate_pc)
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

  if(NOT DEFINED parsed_TARGET)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects a TARGET.")
  endif()

  if(NOT TARGET ${parsed_TARGET})
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
  cmake_path(
    ABSOLUTE_PATH
    template
    BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    NORMALIZE
  )

  set(output "${ARGV1}")
  cmake_path(
    ABSOLUTE_PATH
    output
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    NORMALIZE
  )

  if(parsed_VARIABLES)
    _php_pkgconfig_parse_variables("${parsed_VARIABLES}")
  endif()

  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE outputRelativePath
  )

  get_target_property(type ${parsed_TARGET} TYPE)
  set(fileOption "")
  if(type STREQUAL "EXECUTABLE")
    set(fileOption "" EXECUTABLES "$<TARGET_FILE:${parsed_TARGET}>")
  elseif(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    set(fileOption LIBRARIES "$<TARGET_FILE:${parsed_TARGET}>")
  elseif(type MATCHES "STATIC_LIBRARY")
    set(fileOption "")
  endif()

  string(CONFIGURE [[
    block()
      file(
        GET_RUNTIME_DEPENDENCIES
        RESOLVED_DEPENDENCIES_VAR dependencies
        UNRESOLVED_DEPENDENCIES_VAR unresolvedDependencies
        PRE_EXCLUDE_REGEXES
          libc\\.
          libroot\\.
          ld-linux
          libgcc
          libstdc\\+\\+
        POST_INCLUDE_REGEXES lib[^/]+$
        @fileOption@
      )
      set(libraries "")
      foreach(dependency IN LISTS dependencies)
        cmake_path(GET dependency STEM library)
        list(APPEND libraries "${library}")
      endforeach()
      list(TRANSFORM libraries REPLACE "^lib" "-l")
      list(JOIN libraries " " PHP_LIBS_PRIVATE)

      set(resultVariables @resultVariables@)
      set(resultValues "@resultValues@")

      foreach(var value IN ZIP_LISTS resultVariables resultValues)
        set(${var} "${value}")
      endforeach()

      configure_file("@template@" "@output@" @ONLY)
    endblock()
  ]] code @ONLY)
  install(CODE "${code}")
endfunction()
