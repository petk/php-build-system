#[=============================================================================[
# FindSystemd

Finds the systemd library (libsystemd):

```cmake
find_package(Systemd [<version>] [...])
```

## Imported targets

This module defines the following imported targets:

* `Systemd::Systemd` - The package library, if found.

## Result variables

* `Systemd_FOUND` - Boolean indicating whether the package is found.
* `Systemd_VERSION` - The version of package found.

## Cache variables

* `Systemd_INCLUDE_DIR` - Directory containing package library headers.
* `Systemd_LIBRARY` - The path to the package library.
* `Systemd_EXECUTABLE` - A systemd command-line tool, if available.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Systemd)
target_link_libraries(example PRIVATE Systemd::Systemd)
```
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

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
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
  block(PROPAGATE Systemd_VERSION)
    if(
      NOT Systemd_VERSION
      AND PC_Systemd_VERSION
      AND Systemd_INCLUDE_DIR IN_LIST PC_Systemd_INCLUDE_DIRS
    )
      set(Systemd_VERSION ${PC_Systemd_VERSION})
    endif()

    if(NOT Systemd_VERSION)
      find_program(
        Systemd_EXECUTABLE
        NAMES systemd systemctl
        DOC "Path to the systemd executable"
      )

      if(Systemd_EXECUTABLE)
        execute_process(
          COMMAND "${Systemd_EXECUTABLE}" --version
          OUTPUT_VARIABLE result
          OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(result MATCHES " ([0-9]+) ")
          set(Systemd_VERSION "${CMAKE_MATCH_1}")
        endif()
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
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Systemd_FOUND)
  return()
endif()

if(NOT TARGET Systemd::Systemd)
  add_library(Systemd::Systemd UNKNOWN IMPORTED)

  set_target_properties(
    Systemd::Systemd
    PROPERTIES
      IMPORTED_LOCATION "${Systemd_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Systemd_INCLUDE_DIR}"
  )
endif()
