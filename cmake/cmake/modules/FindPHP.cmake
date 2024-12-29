#[=============================================================================[
# FindPHP

Find PHP on the system, if installed. This is a helper module for using PHP CLI
during the build and development of PHP sources. See also
`ext/skeleton/cmake/modules/FindPHP.cmake` module.

## Result variables

* `PHP_FOUND` - Whether the package has been found.
* `PHP_EXECUTABLE_VERSION` - Package version, if found.

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

set(_reason "")

find_program(
  PHP_EXECUTABLE
  NAMES php
  DOC "Path to the PHP executable"
)
mark_as_advanced(PHP_EXECUTABLE)

if(NOT PHP_EXECUTABLE)
  string(APPEND _reason "The php command-line executable could not be found. ")
endif()

unset(PHP_EXECUTABLE_VERSION)
block(PROPAGATE PHP_EXECUTABLE_VERSION)
  if(PHP_EXECUTABLE)
    execute_process(
      COMMAND ${PHP_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_VARIABLE error
      RESULT_VARIABLE result
    )

    if(NOT result EQUAL 0)
      message(
        SEND_ERROR
        "Command \"${PHP_EXECUTABLE} --version\" failed with output:\n"
        "${error}"
      )
    endif()

    if(version MATCHES "PHP ([0-9]+[0-9.]+[^ ]+) \\(cli\\)")
      set(PHP_EXECUTABLE_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

find_package_handle_standard_args(
  PHP
  REQUIRED_VARS PHP_EXECUTABLE PHP_EXECUTABLE_VERSION
  VERSION_VAR PHP_EXECUTABLE_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
