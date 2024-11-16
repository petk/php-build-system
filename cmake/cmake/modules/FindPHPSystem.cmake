#[=============================================================================[
Find external PHP on the system, if installed.

Result variables:

* `PHPSystem_FOUND` - Whether the package has been found.
* `PHPSystem_VERSION` - Package version, if found.

Cache variables:

* `PHPSystem_EXECUTABLE` - PHP command-line tool, if available.

Hints:

The `PHPSystem_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  PHPSystem
  PROPERTIES
    URL "https://www.php.net"
    DESCRIPTION "PHP: Hypertext Preprocessor"
)

set(_reason "")

find_program(
  PHPSystem_EXECUTABLE
  NAMES php
  DOC "Path to the PHP executable"
)

block(PROPAGATE PHPSystem_VERSION)
  if(PHPSystem_EXECUTABLE)
    execute_process(
      COMMAND "${PHPSystem_EXECUTABLE}" --version
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(version MATCHES "PHP ([^ ]+) ")
      set(PHPSystem_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

mark_as_advanced(PHPSystem_EXECUTABLE)

find_package_handle_standard_args(
  PHPSystem
  REQUIRED_VARS
    PHPSystem_EXECUTABLE
  VERSION_VAR PHPSystem_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
