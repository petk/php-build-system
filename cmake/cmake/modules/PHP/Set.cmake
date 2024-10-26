#[=============================================================================[
Set a CACHE variable that depends on a set of conditions.

> [!WARNING]
> TODO: This module is still under review to determine its usefulness.
> Dependent variables may seem convenient for the application but may create
> difficulties for anyone troubleshooting why a configuration isn't applied,
> even though a configuration value has been set. In the end, build system
> configuration isn't aiming to provide a HTML-form-alike functionality.

At the time of writing, there are 3 main ways in CMake to create non-internal
cache variables that can be also customized from the outside using the `-D`
command-line option, through CMake presets, or similar:
* `option()`
* `set(<variable> <value> CACHE <type> <docstring>)`
* `cmake_dependent_option()`

Ideally, these are the recommended ways to set configuration variables. However,
there are many cases where a `CACHE` variable of a type other than `BOOL`
depends on certain conditions. Additionally, an edge-case issue with
`cmake_dependent_option()` is that it sets a local variable if the conditions
are not met. Local variables in such edge cases can be difficult to work with
when using `add_subdirectory()`. In the parent scope, instead of the local
variable with a forced value, the cached variable is still defined as
`INTERNAL`, which can lead to bugs in the build process.

This module exposes the following function:

```cmake
php_set(
  <variable>
  TYPE <type>
  [CHOICES <string>...]
  [IF <condition> VALUE <value> [ELSE_VALUE <default>]] | [VALUE <value>]
  DOC <docstring>...
  [WARNING <warning>]
)
```

It sets a CACHE `<variable>` of `<type>` to a `<value>`.

* `TYPE` can be `BOOL`, `FILEPATH`, `PATH`, or `STRING`.

* `CHOICES` is an optional list of items when `STRING` type is used to create
  a list of supported options to pick in the GUI. Under the hood, it sets the
  `STRINGS` CACHE variable property.

* `VALUE` is the default variable value. There are two ways to set default
  value.

  * When using the `IF <condition>` argument, it sets the variable to `<value>`
    if `<condition>` is met. Otherwise it sets the `<variable>` to `ELSE_VALUE`
    `<default>` and hides it in the GUI, if `ELSE_VALUE` is given. Under the
    hood `ELSE_VALUE` will set `INTERNAL` cache variable if `<condition>` is not
    met. If `ELSE_VALUE` is not provided, the `INTERNAL` cache variable is not
    set (it is undefined).

    `IF` behaves the same as the `<depends>` argument in the
    `cmake_dependent_option()`. This supports both full condition syntax and
    semicolon-separated list of conditions.

  * When using only `VALUE` signature, it sets the cache variable to `<value>`.
    It is the same as writing:

    ```cmake
    set(<variable> <value> CACHE <type> <docstring>)
    ```

* `DOC` is a short variable help text visible in the GUIs. Multiple strings are
  joined together.

* `WARNING` is optional text that is emitted when setting a variable from the
  command line or CMake presets but its condition is not met. Otherwise, a
  default warning is emitted.
#]=============================================================================]

include_guard(GLOBAL)

function(php_set)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed                     # prefix
    ""                         # options
    "TYPE;IF;VALUE;ELSE_VALUE" # one-value keywords
    "CHOICES;DOC;WARNING"      # multi-value keywords
  )

  # The cmake_parse_arguments() before 3.31 didn't define one-value keywords
  # with empty value of "". This fills the gap and behaves the same until it can
  # be removed. See: https://cmake.org/cmake/help/latest/policy/CMP0174.html
  if(CMAKE_VERSION VERSION_LESS 3.31)
    set(i 0)
    foreach(arg IN LISTS ARGN)
      math(EXPR i "${i}+1")
      foreach(keyword VALUE ELSE_VALUE)
        if(
          arg STREQUAL "${keyword}"
          AND NOT DEFINED parsed_${keyword}
          AND DEFINED ARGV${i}
          AND "${ARGV${i}}" STREQUAL ""
        )
          set(parsed_${keyword} "")
        endif()
      endforeach()
    endforeach()
  endif()

  _php_set_validate_arguments("${ARGN}")

  set(doc "")
  foreach(string ${parsed_DOC})
    string(APPEND doc "${string}")
  endforeach()

  set(condition TRUE)
  if(parsed_IF)
    # Make condition look nice in the possible output strings.
    string(STRIP "${parsed_IF}" parsed_IF)
    string(REGEX REPLACE "[ \t]*[\r\n]+[ \t\r\n]*" "\n" parsed_IF "${parsed_IF}")
    foreach(d ${parsed_IF})
      cmake_language(EVAL CODE "
        if(${d})
        else()
          set(condition FALSE)
        endif()"
      )
    endforeach()
  endif()

  set(varName "${ARGV0}")
  set(bufferVarName ___PHP_SET_${varName})
  set(bufferDoc "Internal storage for ${varName} variable")

  if(NOT DEFINED ${bufferVarName} AND DEFINED ${varName})
    # Initial configuration phase with variable set by the user.
    set(${bufferVarName} "${${varName}}" CACHE INTERNAL "${bufferDoc}")
  elseif(NOT DEFINED ${bufferVarName})
    # Initial configuration phase without variable set by the user.
    set(${bufferVarName} "${parsed_VALUE}" CACHE INTERNAL "${bufferDoc}")
  elseif(
    DEFINED ${bufferVarName}
    AND ${bufferVarName}_OVERRIDDEN
    AND NOT ${varName} STREQUAL "${parsed_ELSE_VALUE}"
  )
    # Consecutive configuration phase that changes the variable after being
    # re-enabled.
    set(${bufferVarName} "${${varName}}" CACHE INTERNAL "${bufferDoc}")
  elseif(DEFINED ${bufferVarName} AND NOT ${bufferVarName}_OVERRIDDEN)
    # Consecutive configuration phase.
    set(${bufferVarName} "${${varName}}" CACHE INTERNAL "${bufferDoc}")
  endif()

  if(condition)
    set(${varName} "${${bufferVarName}}" CACHE ${parsed_TYPE} "${doc}" FORCE)
    if(parsed_TYPE STREQUAL "STRING" AND parsed_CHOICES)
      set_property(CACHE ${varName} PROPERTY STRINGS ${parsed_CHOICES})
    endif()
    unset(${bufferVarName} CACHE)
    unset(${bufferVarName}_OVERRIDDEN CACHE)
  else()
    _php_set_validate_input()

    if(DEFINED parsed_ELSE_VALUE)
      set(${varName} "${parsed_ELSE_VALUE}" CACHE INTERNAL "${doc}" FORCE)
    else()
      unset(${varName} CACHE)
    endif()
    set(
      ${bufferVarName}_OVERRIDDEN
      TRUE
      CACHE INTERNAL
      "Internal marker that ${varName} is overridden."
    )
  endif()
endfunction()

# Validate parsed arguments.
function(_php_set_validate_arguments arguments)
  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT DEFINED parsed_VALUE)
    message(FATAL_ERROR "Missing VALUE argument")
  endif()

  if(NOT parsed_TYPE)
    message(FATAL_ERROR "Missing TYPE argument")
  elseif(NOT parsed_TYPE MATCHES "^(BOOL|FILEPATH|PATH|STRING)$")
    message(FATAL_ERROR "Unknown TYPE argument: ${parsed_TYPE}")
  endif()

  list(FIND arguments ELSE_VALUE elseValueIndex)
  if(NOT DEFINED parsed_IF AND NOT elseValueIndex EQUAL -1)
    message(FATAL_ERROR "Redundant ELSE_VALUE argument without IF condition")
  elseif(
    DEFINED parsed_IF
    AND NOT DEFINED parsed_ELSE_VALUE
    AND NOT elseValueIndex EQUAL -1
  )
    message(FATAL_ERROR "Missing ELSE_VALUE argument")
  endif()

  if(NOT DEFINED parsed_DOC)
    message(FATAL_ERROR "Missing DOC argument")
  endif()
endfunction()

# Output warning when setting conditional variable and condition is not met.
function(_php_set_validate_input)
  get_property(helpString CACHE ${varName} PROPERTY HELPSTRING)
  if(NOT helpString STREQUAL "No help, variable specified on the command line.")
    return()
  endif()

  if(NOT parsed_WARNING)
    set(parsed_WARNING "Variable ${varName}")
    if(DEFINED parsed_ELSE_VALUE)
      string(
        APPEND
        parsed_WARNING
        " has been overridden (${varName}=${parsed_ELSE_VALUE})"
      )
    else()
      string(
        APPEND
        parsed_WARNING
        " has been overridden to an undefined state"
      )
    endif()
    string(
      APPEND
      parsed_WARNING
      " as it depends on the condition:\n"
      "${parsed_IF}\n"
    )
  endif()
  set(warning "")
  foreach(string ${parsed_WARNING})
    string(APPEND warning "${string}")
  endforeach()

  if(NOT ${varName} STREQUAL "${parsed_ELSE_VALUE}")
    message(WARNING "${warning}")
  endif()
endfunction()
