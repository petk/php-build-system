#[=============================================================================[
# FindSELinux

Finds the SELinux library:

```cmake
find_package(SELinux [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `SELinux::SELinux` - The package library, if found.

## Result variables

* `SELinux_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `SELinux_VERSION` - The version of package found.

## Cache variables

* `SELinux_INCLUDE_DIR` - Directory containing package library headers.
* `SELinux_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(SELinux)
target_link_libraries(example PRIVATE SELinux::SELinux)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  SELinux
  PROPERTIES
    URL "http://selinuxproject.org/"
    DESCRIPTION "Security Enhanced Linux"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_Selinux QUIET libselinux)
endif()

find_path(
  SELinux_INCLUDE_DIR
  NAMES selinux/selinux.h
  HINTS ${PC_Selinux_INCLUDE_DIRS}
  DOC "Directory containing SELinux library headers"
)

if(NOT SELinux_INCLUDE_DIR)
  string(APPEND _reason "selinux/selinux.h not found. ")
endif()

find_library(
  SELinux_LIBRARY
  NAMES selinux
  HINTS ${PC_Selinux_LIBRARY_DIRS}
  DOC "The path to the SELinux library"
)

if(NOT SELinux_LIBRARY)
  string(APPEND _reason "SELinux library (libselinux) not found. ")
endif()

# SELinux headers don't provide version. Try pkg-config.
if(PC_SELinux_VERSION AND SELinux_INCLUDE_DIR IN_LIST PC_SELinux_INCLUDE_DIRS)
  set(SELinux_VERSION ${PC_SELinux_VERSION})
endif()

mark_as_advanced(SELinux_INCLUDE_DIR SELinux_LIBRARY)

find_package_handle_standard_args(
  SELinux
  REQUIRED_VARS
    SELinux_LIBRARY
    SELinux_INCLUDE_DIR
  VERSION_VAR SELinux_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT SELinux_FOUND)
  return()
endif()

if(NOT TARGET SELinux::SELinux)
  add_library(SELinux::SELinux UNKNOWN IMPORTED)

  set_target_properties(
    SELinux::SELinux
    PROPERTIES
      IMPORTED_LOCATION "${SELinux_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${SELinux_INCLUDE_DIR}"
  )
endif()
