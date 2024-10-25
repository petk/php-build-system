#[=============================================================================[
Set a CACHE variable that depends on a set of conditions.

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
#]=============================================================================]

include_guard(GLOBAL)

function(php_set)
  # https://cmake.org/cmake/help/latest/policy/CMP0174.html
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.31)
    set(valueNew "VALUE")
    set(elseValueNew "ELSE_VALUE")
  else()
    set(valueOld "VALUE")
    set(elseValueOld "ELSE_VALUE")
  endif()

  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed                                    # prefix
    ""                                        # options
    "${valueNew};TYPE;IF;${elseValueNew}"     # one-value keywords
    "${valueOld};CHOICES;DOC;${elseValueOld}" # multi-value keywords
  )

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

  if(NOT DEFINED parsed_IF AND DEFINED parsed_ELSE_VALUE)
    message(FATAL_ERROR "Redundant ELSE_VALUE argument without IF condition")
  endif()

  if(NOT DEFINED parsed_DOC)
    message(FATAL_ERROR "Missing DOC argument")
  endif()

  set(doc "")
  foreach(string ${parsed_DOC})
    string(APPEND doc "${string}")
  endforeach()

  set(condition TRUE)
  if(parsed_IF)
    foreach(d ${parsed_IF})
      cmake_language(EVAL CODE "
        if(${d})
        else()
          set(condition FALSE)
        endif()"
      )
    endforeach()
  endif()

  set(var "${ARGV0}")
  set(internal ___PHP_SET_${var})

  if(NOT DEFINED ${internal} AND DEFINED ${var})
    # Initial configuration phase with variable set by the user.
    set(${internal} "${${var}}" CACHE INTERNAL "Internal storage for ${var}")
  elseif(NOT DEFINED ${internal})
    # Initial configuration phase without variable set by the user.
    set(${internal} "${parsed_VALUE}" CACHE INTERNAL "Internal storage for ${var}")
  elseif(
    DEFINED ${internal}
    AND ${internal}_FORCED
    AND NOT ${var} STREQUAL "${parsed_ELSE_VALUE}"
  )
    # Consecutive configuration phase that changes the variable after being
    # re-enabled.
    set(${internal} "${${var}}" CACHE INTERNAL "Internal storage for ${var}")
  elseif(DEFINED ${internal} AND NOT ${internal}_FORCED)
    # Consecutive configuration phase.
    set(${internal} "${${var}}" CACHE INTERNAL "Internal storage for ${var}")
  endif()

  if(condition)
    set(${var} "${${internal}}" CACHE ${parsed_TYPE} "${doc}" FORCE)
    if(parsed_TYPE STREQUAL "STRING" AND parsed_CHOICES)
      set_property(CACHE ${var} PROPERTY STRINGS ${parsed_CHOICES})
    endif()
    unset(${internal} CACHE)
    unset(${internal}_FORCED CACHE)
  else()
    if(DEFINED parsed_ELSE_VALUE)
      set(${var} "${parsed_ELSE_VALUE}" CACHE INTERNAL "${doc}")
    else()
      unset(${var} CACHE)
    endif()
    set(
      ${internal}_FORCED
      TRUE
      CACHE INTERNAL
      "Internal marker that ${var} has a forced value."
    )
  endif()
endfunction()
