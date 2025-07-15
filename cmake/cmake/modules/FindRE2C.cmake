#[=============================================================================[
# FindRE2C

Finds the `re2c` command-line lexer generator:

```cmake
find_package(RE2C)
```

## Result variables

* `RE2C_FOUND` - Whether the `re2c` was found.
* `RE2C_VERSION` - The `re2c` version.

## Cache variables

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

################################################################################
# Configuration.
################################################################################

set_package_properties(
  RE2C
  PROPERTIES
    URL "https://re2c.org/"
    DESCRIPTION "Lexer generator"
)

################################################################################
# Find the executable.
################################################################################

set(_re2cRequiredVars RE2C_EXECUTABLE)
set(_reason "")

find_program(
  RE2C_EXECUTABLE
  NAMES re2c
  DOC "The path to the re2c executable"
)
mark_as_advanced(RE2C_EXECUTABLE)

if(NOT RE2C_EXECUTABLE)
  string(APPEND _reason "The re2c command-line executable not found. ")
endif()

################################################################################
# Check version.
################################################################################

block(PROPAGATE RE2C_VERSION _reason _re2cRequiredVars)
  if(IS_EXECUTABLE "${RE2C_EXECUTABLE}")
    list(APPEND _re2cRequiredVars RE2C_VERSION)
    execute_process(
      COMMAND ${RE2C_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
      string(APPEND _reason "Command '${RE2C_EXECUTABLE} --version' failed. ")
    elseif(version MATCHES "^re2c ([0-9.]+[^\n]+)")
      set(RE2C_VERSION "${CMAKE_MATCH_1}")
    else()
      string(APPEND _reason "Invalid version format. ")
    endif()
  endif()
endblock()

find_package_handle_standard_args(
  RE2C
  REQUIRED_VARS ${_re2cRequiredVars}
  VERSION_VAR RE2C_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_re2cRequiredVars)
unset(_reason)
