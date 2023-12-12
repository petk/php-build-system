#[=============================================================================[
Find the systemd library (libsystemd).

Module defines the following IMPORTED targets:

  Systemd::Systemd
    The systemd library, if found.

Result variables:

  Systemd_FOUND
    Whether systemd library is found.
  Systemd_INCLUDE_DIRS
    A list of include directories for using systemd library.
  Systemd_LIBRARIES
    A list of libraries for using systemd library.
  Systemd_EXECUTABLE
    A systemd command-line tool if available.
  Systemd_VERSION
    Version string of found systemd library if available.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Systemd PROPERTIES
  URL "https://www.freedesktop.org/wiki/Software/systemd/"
  DESCRIPTION "System and service manager library"
)

set(_reason_failure_message)

find_path(
  Systemd_INCLUDE_DIRS
  NAMES systemd/sd-daemon.h
  DOC "The systemd include directories"
)

if(NOT Systemd_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    systemd/sd-daemon.h couldn't be found. System doesn't support systemd."
  )
endif()

find_library(Systemd_LIBRARIES NAMES systemd DOC "The systemd library")

if(NOT Systemd_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    The systemd not found. Please install systemd library."
  )
endif()

find_program(
  Systemd_EXECUTABLE
  NAMES systemd systemctl
  DOC "The systemd executable"
)

if(Systemd_EXECUTABLE)
  execute_process(
    COMMAND ${Systemd_EXECUTABLE} --version
    OUTPUT_VARIABLE Systemd_VERSION_STRING
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  string(REGEX MATCH " ([0-9]+) " _ "${Systemd_VERSION_STRING}")

  if(CMAKE_MATCH_1)
    set(Systemd_VERSION "${CMAKE_MATCH_1}")
  endif()
endif()

if(Systemd_VERSION)
  set(_systemd_version_argument VERSION_VAR Systemd_VERSION)
endif()

find_package_handle_standard_args(
  Systemd
  REQUIRED_VARS Systemd_LIBRARIES Systemd_INCLUDE_DIRS
  ${_systemd_version_argument}
  REASON_FAILURE_MESSAGE "${reason_failure_message}"
)

unset(_reason_failure_message)
unset(_systemd_version_argument)

if(Systemd_FOUND AND NOT TARGET Systemd::Systemd)
  add_library(Systemd::Systemd INTERFACE IMPORTED)

  set_target_properties(Systemd::Systemd PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Systemd_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Systemd_LIBRARIES}"
  )
endif()
