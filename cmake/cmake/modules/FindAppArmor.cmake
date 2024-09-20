#[=============================================================================[
Find the AppArmor library.

Module defines the following `IMPORTED` target(s):

* `AppArmor::AppArmor` - The package library, if found.

Result variables:

* `AppArmor_FOUND` - Whether the package has been found.
* `AppArmor_INCLUDE_DIRS` - Include directories needed to use this package.
* `AppArmor_LIBRARIES` - Libraries needed to link to the package library.
* `AppArmor_VERSION` - Package version, if found.

Cache variables:

* `AppArmor_INCLUDE_DIR` - Directory containing package library headers.
* `AppArmor_LIBRARY` - The path to the package library.

Hints:

The `AppArmor_ROOT` variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  AppArmor
  PROPERTIES
    URL "https://apparmor.net/"
    DESCRIPTION "Kernel security module library to confine programs"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_AppArmor QUIET libapparmor)

find_path(
  AppArmor_INCLUDE_DIR
  NAMES sys/apparmor.h
  PATHS ${PC_AppArmor_INCLUDE_DIRS}
  DOC "Directory containing AppArmor library headers"
)

if(NOT AppArmor_INCLUDE_DIR)
  string(APPEND _reason "sys/apparmor.h not found. ")
endif()

find_library(
  AppArmor_LIBRARY
  NAMES apparmor
  PATHS ${PC_AppArmor_LIBRARY_DIRS}
  DOC "The path to the AppArmor library"
)

if(NOT AppArmor_LIBRARY)
  string(APPEND _reason "AppArmor library not found. ")
endif()

# Sanity check.
if(AppArmor_LIBRARY)
  check_library_exists(
    "${AppArmor_LIBRARY}"
    aa_change_profile
    ""
    _apparmor_sanity_check
  )
endif()

if(NOT _apparmor_sanity_check)
  string(APPEND _reason "Sanity check failed: aa_change_profile not found. ")
endif()

# Get version.
block(PROPAGATE AppArmor_VERSION)
  # AppArmor headers don't provide version. Try pkgconf version, if found.
  if(PC_AppArmor_VERSION)
    cmake_path(
      COMPARE
      "${PC_AppArmor_INCLUDEDIR}" EQUAL "${AppArmor_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(AppArmor_VERSION ${PC_AppArmor_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(AppArmor_INCLUDE_DIR AppArmor_LIBRARY)

find_package_handle_standard_args(
  AppArmor
  REQUIRED_VARS
    AppArmor_LIBRARY
    AppArmor_INCLUDE_DIR
    _apparmor_sanity_check
  VERSION_VAR AppArmor_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT AppArmor_FOUND)
  return()
endif()

set(AppArmor_INCLUDE_DIRS ${AppArmor_INCLUDE_DIR})
set(AppArmor_LIBRARIES ${AppArmor_LIBRARY})

if(NOT TARGET AppArmor::AppArmor)
  add_library(AppArmor::AppArmor UNKNOWN IMPORTED)

  set_target_properties(
    AppArmor::AppArmor
    PROPERTIES
      IMPORTED_LOCATION "${AppArmor_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${AppArmor_INCLUDE_DIR}"
  )
endif()
