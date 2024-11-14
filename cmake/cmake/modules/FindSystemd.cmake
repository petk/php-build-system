#[=============================================================================[
Find the systemd library (libsystemd).

Module defines the following `IMPORTED` target(s):

* `Systemd::Systemd` - The package library, if found.

Result variables:

* `Systemd_FOUND` - Whether the package has been found.
* `Systemd_INCLUDE_DIRS` - Include directories needed to use this package.
* `Systemd_LIBRARIES` - Libraries needed to link to the package library.
* `Systemd_VERSION` - Package version, if found.

Cache variables:

* `Systemd_INCLUDE_DIR` - Directory containing package library headers.
* `Systemd_LIBRARY` - The path to the package library.
* `Systemd_EXECUTABLE` - A systemd command-line tool, if available.

Hints:

The `Systemd_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Systemd
  PROPERTIES
    URL "https://www.freedesktop.org/wiki/Software/systemd/"
    DESCRIPTION "System and service manager library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Systemd QUIET libsystemd)
endif()

find_path(
  Systemd_INCLUDE_DIR
  NAMES systemd/sd-daemon.h
  HINTS ${PC_Systemd_INCLUDE_DIRS}
  DOC "Directory containing systemd library headers"
)

if(NOT Systemd_INCLUDE_DIR)
  string(APPEND _reason "systemd/sd-daemon.h not found. ")
endif()

find_library(
  Systemd_LIBRARY
  NAMES systemd
  HINTS ${PC_Systemd_LIBRARY_DIRS}
  DOC "The path to the systemd library"
)

if(NOT Systemd_LIBRARY)
  string(APPEND _reason "The systemd library not found. ")
endif()

if(Systemd_INCLUDE_DIR AND Systemd_LIBRARY)
  find_program(
    Systemd_EXECUTABLE
    NAMES systemd systemctl
    DOC "Path to the systemd executable"
  )

  block(PROPAGATE Systemd_VERSION)
    if(Systemd_EXECUTABLE)
      execute_process(
        COMMAND "${Systemd_EXECUTABLE}" --version
        OUTPUT_VARIABLE result
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      string(REGEX MATCH " ([0-9]+) " _ "${result}")

      if(CMAKE_MATCH_1)
        set(Systemd_VERSION "${CMAKE_MATCH_1}")
      endif()
    endif()

    # Try finding version with pkgconf.
    if(NOT Systemd_VERSION AND PC_Systemd_VERSION)
      cmake_path(
        COMPARE
        "${PC_Systemd_INCLUDEDIR}" EQUAL "${Systemd_INCLUDE_DIR}"
        isEqual
      )

      if(isEqual)
        set(Systemd_VERSION ${PC_Systemd_VERSION})
      endif()
    endif()
  endblock()
endif()

mark_as_advanced(Systemd_INCLUDE_DIR Systemd_LIBRARY Systemd_EXECUTABLE)

find_package_handle_standard_args(
  Systemd
  REQUIRED_VARS
    Systemd_LIBRARY
    Systemd_INCLUDE_DIR
  VERSION_VAR Systemd_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Systemd_FOUND)
  return()
endif()

set(Systemd_INCLUDE_DIRS ${Systemd_INCLUDE_DIR})
set(Systemd_LIBRARIES ${Systemd_LIBRARY})

if(NOT TARGET Systemd::Systemd)
  add_library(Systemd::Systemd UNKNOWN IMPORTED)

  set_target_properties(
    Systemd::Systemd
    PROPERTIES
      IMPORTED_LOCATION "${Systemd_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Systemd_INCLUDE_DIR}"
  )
endif()
