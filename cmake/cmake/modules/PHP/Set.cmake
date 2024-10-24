#[=============================================================================[
Set a CACHE variable that depends on a set of conditions.

In CMake there are 3 main ways to create non-internal cache variables that can
be also customized using the `-D` command-line option, through CMake presets, or
similar:
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
  <default>
  CACHE <type>
  [STRINGS <string>...]
  [DOC <docstring>...]
  IF <condition>
  FORCED <forced>
)
```

It sets the given CACHE `<variable>` of `<type>` to a `<value>` if `<condition>`
is met. Otherwise it sets the `<variable>` to `<default>` value and hides it in
the GUI.

* The `CACHE` `<type>` can be `BOOL`, `FILEPATH`, `PATH`, or `STRING`.

* `STRINGS` is an optional list of items when `CACHE` `STRING` is used to create
  a list of supported options to pick in the GUI.

* `DOC` is a short variable help text visible in the GUIs. Multiple strings are
  joined together.

* `IF` behaves the same as the `<depends>` argument in
  `cmake_dependent_option()`. If conditions `<condition>` are met, the variable
  is set to `<default>` value. Otherwise, it is set to `<forced>` value and
  hidden in the GUIs. This supports both full condition sytanx and
  semicolon-separated list of conditions.

* `FORCED` is a value that is set when `IF <conditions>` are not met.
#]=============================================================================]

include_guard(GLOBAL)

function(php_set)
  cmake_parse_arguments(
    PARSE_ARGV
    2
    parsed               # prefix
    ""                   # options
    "CACHE;IF"           # one-value keywords
    "STRINGS;DOC;FORCED" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT parsed_CACHE)
    message(FATAL_ERROR "Missing CACHE type argument")
  elseif(NOT parsed_CACHE MATCHES "^(BOOL|FILEPATH|PATH|STRING)$")
    message(FATAL_ERROR "Unknown CACHE type argument: ${parsed_CACHE}")
  endif()

  if(NOT parsed_IF)
    message(FATAL_ERROR "Missing IF argument with condition")
  endif()

  if(NOT DEFINED parsed_FORCED)
    message(FATAL_ERROR "Missing FORCED argument")
  endif()

  set(doc "")
  foreach(string ${parsed_DOC})
    string(APPEND doc "${string}")
  endforeach()

  set(condition TRUE)
  foreach(d ${parsed_IF})
    cmake_language(EVAL CODE "
      if(${d})
      else()
        set(condition FALSE)
      endif()"
    )
  endforeach()

  set(var "${ARGV0}")
  set(internal ___PHP_SET_${var})

  if(NOT DEFINED ${internal} AND DEFINED ${var})
    set(${internal} "${${var}}" CACHE INTERNAL "Internal storage for ${var}")
  elseif(NOT DEFINED ${internal})
    set(${internal} "${ARGV1}" CACHE INTERNAL "Internal storage for ${var}")
  elseif(DEFINED ${internal} AND NOT ${internal}_FORCED)
    set(${internal} "${${var}}" CACHE INTERNAL "Internal storage for ${var}")
  endif()

  if(condition)
    set(${var} "${${internal}}" CACHE ${parsed_CACHE} "${doc}" FORCE)
    if(parsed_CACHE STREQUAL "STRING" AND parsed_STRINGS)
      set_property(CACHE ${var} PROPERTY STRINGS ${parsed_STRINGS})
    endif()
    unset(${internal} CACHE)
    unset(${internal}_FORCED CACHE)
  else()
    set(${var} "${parsed_FORCED}" CACHE INTERNAL "${doc}")
    set(
      ${internal}_FORCED
      TRUE
      CACHE INTERNAL
      "Internal marker that ${var} has a forced value."
    )
  endif()
endfunction()
