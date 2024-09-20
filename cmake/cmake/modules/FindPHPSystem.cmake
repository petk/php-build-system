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
  NAMES
    php
    php8.4
    php84
    php8.3
    php83
    php8.2
    php82
    php8.1
    php81
    php8
    php7.4
    php74
    php7

  DOC "Path to the PHP executable"
)

block(PROPAGATE PHPSystem_VERSION)
  if(PHPSystem_EXECUTABLE)
    execute_process(
      COMMAND "${PHPSystem_EXECUTABLE}" --version
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    string(REGEX MATCH "PHP ([^ ]+) " _ "${version}")

    if(CMAKE_MATCH_1)
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
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
