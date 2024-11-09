#[=============================================================================[
Set a CACHE variable that depends on a set of conditions.

At the time of writing, there are three main ways in CMake to create
non-internal cache variables that can also be customized externally via the `-D`
command-line option, CMake presets, or similar:

* `option()`
* `set(<variable> <value> CACHE <type> <docstring>)`
* `cmake_dependent_option()`

Ideally, these are the recommended methods to set configuration variables.
However, there are cases where a `CACHE` variable of a type other than `BOOL`
depends on specific conditions. Additionally, an edge-case issue with
`cmake_dependent_option()` is that it sets a local variable if the conditions
are not met. Local variables in such cases can be difficult to work with
when using `add_subdirectory()`. In the parent scope, instead of a local
variable with a forced value, the cached variable is still defined as
`INTERNAL`, which can lead to bugs in the build process.

## The `php_set()` function

```cmake
php_set(
  <variable>
  TYPE <type>
  [IF <condition> VALUE <value> [ELSE_VALUE <default>]] | [VALUE <value>]
  DOC <docstring>...
)
```

This function sets a cache `<variable>` of `<type>` to a `<value>`.

* `TYPE` can be `BOOL`, `FILEPATH`, `PATH`, or `STRING`.

* `VALUE` is the default variable value. There are two ways to set the default
  value.

  * When using the `IF <condition>` argument, it sets the variable to `<value>`
    if `<condition>` is met. Otherwise it sets the `<variable>` to `ELSE_VALUE`
    `<default>` and hides it in the GUI if `ELSE_VALUE` is provided. Internally,
    `ELSE_VALUE` will set an `INTERNAL` cache variable if `<condition>` is not
    met. If `ELSE_VALUE` is not provided, the `INTERNAL` cache variable is not
    set (it is undefined).

    `IF` behaves the same as the `<depends>` argument in the
    `cmake_dependent_option()`. This supports both full condition syntax and
    semicolon-separated list of conditions.

  * When using only `VALUE` signature, it sets the cache variable to `<value>`,
    which is equivalent to writing:

    ```cmake
    set(<variable> <value> CACHE <type> <docstring>)
    ```

* `DOC` is a short help text for the variable, visible in GUIs. Multiple strings
  are joined together.

  For example:

  ```cmake
  php_set(
    VAR
    TYPE STRING
    IF [[CMAKE_SYSTEM_NAME STREQUAL "Linux"]]
    VALUE "some value"
    DOC
      "This help text "
      "is joined "
      "together."
  )
  ```

## The `CHOICES` signature

The `CHOICES` signature provides a list of options to choose from:

```cmake
php_set(
  <variable>
  [TYPE STRING]
  CHOICES <string>...
  [CHOICES_OPTIONAL]
  [CHOICES_CASE_SENSITIVE]
  [IF <condition> [VALUE <value>] [ELSE_VALUE <default>]] | [VALUE <value>]
  DOC <docstring>...
)
```

* `CHOICES` is a list of items to choose from in the GUI. Internally, it sets
  the `STRINGS` cache variable property. The default `TYPE` is `STRING`, which
  is optional.

  When using `CHOICES`, the `VALUE` keyword is optional. The default variable
  value is set to the first item in the `CHOICES` list.

  For example:

  ```cmake
  include(PHP/Set)
  php_set(
    VAR
    CHOICES auto on off
    DOC "Variable with default value set to the first list item"
  )
  message(STATUS "VAR=${VAR}")
  ```

  Output:

  ```
  VAR=auto
  ```

* When `CHOICES_OPTIONAL` is given, the variable value will not be required to
  match one of the list items. By default, when using `CHOICES`, the variable
  value must match one of the list items; otherwise, a fatal error is thrown.

  For example:

  ```cmake
  php_set(
    VAR
    CHOICES auto on off
    CHOICES_OPTIONAL
    DOC
      "Variable with optional predefined choices where its value can be also "
      "changed to anything else."
  )
  message(STATUS "VAR=${VAR}")
  ```

  ```sh
  cmake -S <source-dir> -B <build-dir> -D VAR=overridden
  ```

  Output:

  ```
  VAR=overridden
  ```

* When `CHOICES_CASE_SENSITIVE` is given, the variable value will need to match
  the case of item defined in the `CHOICES` list. By default, choices are
  case-insensitive.

  For example:

  ```cmake
  php_set(
    VAR
    CHOICES auto unixODBC iODBC
    DOC "Variable with a case-insensitive list of choices"
  )
  message(STATUS "VAR=${VAR}")
  ```

  ```sh
  cmake -S <source-dir> -B <build-dir> -D VAR=unixodbc
  ```

  Will output `VAR=unixODBC` and not `VAR=unixodbc`.

  With `CHOICES_CASE_SENSITIVE`:

  ```cmake
  php_set(
    VAR
    CHOICES auto unixODBC iODBC
    CHOICES_CASE_SENSITIVE
    DOC "Variable with a case-sensitive list of choices"
  )
  message(STATUS "VAR=${VAR}")
  ```

  A fatal error will be thrown, if `VAR` is set to a case-sensitive value
  (`unixodbc`) that does not match any item in the `CHOICES` list.
#]=============================================================================]

include_guard(GLOBAL)

function(php_set)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed # prefix
    "CHOICES_OPTIONAL;CHOICES_CASE_SENSITIVE" # options
    "TYPE;IF;VALUE;ELSE_VALUE" # one-value keywords
    "CHOICES;DOC" # multi-value keywords
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

  # Set default TYPE if not set when using CHOICES argument.
  if(DEFINED parsed_CHOICES AND NOT DEFINED parsed_TYPE)
    set(parsed_TYPE "STRING")
  endif()

  _php_set_validate_arguments("${ARGN}")

  set(doc "")
  foreach(string ${parsed_DOC})
    string(APPEND doc "${string}")
  endforeach()

  set(condition TRUE)
  if(DEFINED parsed_IF)
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
    # Initial configuration phase with variable set externally.
    set(${bufferVarName} "${${varName}}" CACHE INTERNAL "${bufferDoc}")
  elseif(NOT DEFINED ${bufferVarName})
    # Initial configuration phase without variable set externally.

    # When using CHOICES and VALUE is not set, set the variable value to the
    # first item of the CHOICES list.
    if(
      parsed_TYPE STREQUAL "STRING"
      AND DEFINED parsed_CHOICES
      AND NOT DEFINED parsed_VALUE
    )
      list(GET parsed_CHOICES 0 value)
      set(parsed_VALUE "${value}")
      unset(value)
    endif()
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
      set_property(CACHE ${varName} PROPERTY STRINGS "${parsed_CHOICES}")
      if(NOT parsed_CHOICES_CASE_SENSITIVE)
        _php_set_adjust_case_sensitivity_value(${varName})
      endif()
      if(NOT parsed_CHOICES_OPTIONAL)
        _php_set_validate_choices(${varName} ${parsed_CHOICES_CASE_SENSITIVE})
      endif()
    endif()

    unset(${bufferVarName} CACHE)
    unset(${bufferVarName}_OVERRIDDEN CACHE)
  else()
    _php_set_validate_input(${varName})

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

  if(
    NOT DEFINED parsed_VALUE
    AND (NOT DEFINED parsed_CHOICES OR NOT parsed_TYPE STREQUAL "STRING")
  )
    message(FATAL_ERROR "Missing VALUE argument")
  endif()

  if(NOT parsed_TYPE)
    message(FATAL_ERROR "Missing TYPE argument")
  elseif(NOT parsed_TYPE MATCHES "^(BOOL|FILEPATH|PATH|STRING)$")
    message(FATAL_ERROR "Unknown TYPE argument: ${parsed_TYPE}")
  endif()

  if(DEFINED parsed_CHOICES AND NOT parsed_TYPE STREQUAL "STRING")
    message(FATAL_ERROR "CHOICES argument can be only used with TYPE STRING")
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

# Validate variable and output warning when a conditional variable is set
# externally and the condition is not met. This is for diagnostic purpose for
# user to be aware that some configuration value was not taken into account.
function(_php_set_validate_input var)
  get_property(helpString CACHE ${var} PROPERTY HELPSTRING)
  if(NOT helpString STREQUAL "No help, variable specified on the command line.")
    return()
  endif()

  if(${var} STREQUAL "${parsed_ELSE_VALUE}")
    return()
  endif()

  set(warning "Variable ${var}")
  if(DEFINED parsed_ELSE_VALUE)
    string(APPEND warning " has been overridden (${var}=${parsed_ELSE_VALUE})")
  else()
    string(APPEND warning " has been undefined")
  endif()
  string(
    APPEND
    warning
    " as it depends on the condition:\n"
    "${parsed_IF}\n"
    "The ${var} configuration value can be then probably removed from the "
    "current build command as it won't be utilized."
  )

  message(WARNING "${warning}")
endfunction()

# Adjust the variable value according to the case sensitivity as defined in the
# CHOICES list item.
function(_php_set_adjust_case_sensitivity_value var)
  get_property(value CACHE ${var} PROPERTY VALUE)
  get_property(choices CACHE ${var} PROPERTY STRINGS)

  string(TOLOWER "${value}" valueLower)
  list(TRANSFORM choices TOLOWER OUTPUT_VARIABLE choicesLower)

  set(index 0)
  foreach(item IN LISTS choicesLower)
    if(valueLower STREQUAL "${item}")
      list(GET choices ${index} itemOriginal)
      if(NOT value STREQUAL "${itemOriginal}")
        set_property(CACHE ${var} PROPERTY VALUE ${itemOriginal})
        break()
      endif()
    endif()
    math(EXPR index "${index}+1")
  endforeach()
endfunction()

# Validate variable value to match with one of the items from the CHOICES list.
function(_php_set_validate_choices var caseSensitive)
  get_property(value CACHE ${var} PROPERTY VALUE)
  get_property(choices CACHE ${var} PROPERTY STRINGS)

  if(NOT caseSensitive)
    string(TOLOWER "${value}" value)
    list(TRANSFORM choices TOLOWER)
  endif()

  if(NOT value IN_LIST choices)
    list(JOIN choices ", " choices)

    message(
      FATAL_ERROR
      "Unknown value: ${var}=${value}\n"
      "Please select one of: ${choices}."
    )
  endif()
endfunction()
