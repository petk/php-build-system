#[=============================================================================[
# FindRE2C

Finds the `re2c` command-line lexer generator:

```cmake
find_package(RE2C [<version>] [...])
```

## Result variables

This module defines the following variables:

* `RE2C_FOUND` - Boolean indicating whether (the requested version of) `re2c`
  was found.
* `RE2C_VERSION` - The version of `re2c` found.

## Cache variables

The following cache variables may also be set:

* `RE2C_EXECUTABLE` - Path to the `re2c` executable.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(RE2C)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

block(PROPAGATE RE2C_FOUND RE2C_VERSION)
  ##############################################################################
  # Configuration.
  ##############################################################################

  set_package_properties(
    RE2C
    PROPERTIES
      URL "https://re2c.org/"
      DESCRIPTION "Lexer generator"
  )

  set(required_vars RE2C_EXECUTABLE)
  set(reason "")

  ##############################################################################
  # Find the executable.
  ##############################################################################

  find_program(
    RE2C_EXECUTABLE
    NAMES re2c
    DOC "The path to the re2c executable"
  )
  mark_as_advanced(RE2C_EXECUTABLE)

  if(NOT RE2C_EXECUTABLE)
    string(APPEND reason "The re2c command-line executable not found. ")
  endif()

  ##############################################################################
  # Check version.
  ##############################################################################

  if(IS_EXECUTABLE "${RE2C_EXECUTABLE}")
    list(APPEND required_vars RE2C_VERSION)
    execute_process(
      COMMAND ${RE2C_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
      string(APPEND reason "Command '${RE2C_EXECUTABLE} --version' failed. ")
    elseif(version MATCHES "^re2c ([0-9.]+[^\n]+)")
      set(RE2C_VERSION "${CMAKE_MATCH_1}")
    else()
      string(APPEND reason "Invalid version format. ")
    endif()
  endif()

  find_package_handle_standard_args(
    RE2C
    REQUIRED_VARS ${required_vars}
    VERSION_VAR RE2C_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )
endblock()
