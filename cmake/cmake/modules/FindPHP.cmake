#[=============================================================================[
# FindPHP

Find PHP on the system, if installed.

## Result variables

* `PHP_FOUND` - Whether the package has been found.
* `PHP_VERSION` - Package version, if found.

## Cache variables

* `PHP_EXECUTABLE` - PHP command-line executable, if available.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  PHP
  PROPERTIES
    URL "https://www.php.net"
    DESCRIPTION "PHP: Hypertext Preprocessor"
)

set(_phpRequiredVars PHP_EXECUTABLE)
set(_reason "")

find_program(
  PHP_EXECUTABLE
  NAMES php
  DOC "The path to the PHP executable"
)
mark_as_advanced(PHP_EXECUTABLE)

if(NOT PHP_EXECUTABLE)
  string(APPEND _reason "The php command-line executable could not be found. ")
endif()

unset(PHP_VERSION)
block(PROPAGATE PHP_VERSION _reason _phpRequiredVars)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
    set(test IS_EXECUTABLE)
  else()
    set(test EXISTS)
  endif()

  if(${test} ${PHP_EXECUTABLE})
    list(APPEND _phpRequiredVars PHP_VERSION)

    execute_process(
      COMMAND ${PHP_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    if(NOT result EQUAL 0)
      string(APPEND _reason "Command '${PHP_EXECUTABLE} --version' failed. ")
    elseif(version MATCHES "PHP ([0-9]+[0-9.]+[^ ]+) \\(cli\\)")
      set(PHP_VERSION "${CMAKE_MATCH_1}")
    else()
      string(APPEND _reason "Invalid version format. ")
    endif()
  endif()
endblock()

find_package_handle_standard_args(
  PHP
  REQUIRED_VARS ${_phpRequiredVars}
  VERSION_VAR PHP_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_phpRequiredVars)
unset(_reason)
