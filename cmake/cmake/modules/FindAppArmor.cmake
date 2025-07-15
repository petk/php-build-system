#[=============================================================================[
# FindAppArmor

Finds the AppArmor library:

```cmake
find_package(AppArmor)
```

## Imported targets

This module defines the following imported targets:

* `AppArmor::AppArmor` - The package library, if found.

## Result variables

* `AppArmor_FOUND` - Whether the package has been found.
* `AppArmor_INCLUDE_DIRS` - Include directories needed to use this package.
* `AppArmor_LIBRARIES` - Libraries needed to link to the package library.
* `AppArmor_VERSION` - Package version, if found.

## Cache variables

* `AppArmor_INCLUDE_DIR` - Directory containing package library headers.
* `AppArmor_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(AppArmor)
target_link_libraries(example PRIVATE AppArmor::AppArmor)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  AppArmor
  PROPERTIES
    URL "https://apparmor.net/"
    DESCRIPTION "Kernel security module library to confine programs"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_AppArmor QUIET libapparmor)
endif()

find_path(
  AppArmor_INCLUDE_DIR
  NAMES sys/apparmor.h
  HINTS ${PC_AppArmor_INCLUDE_DIRS}
  DOC "Directory containing AppArmor library headers"
)

if(NOT AppArmor_INCLUDE_DIR)
  string(APPEND _reason "sys/apparmor.h not found. ")
endif()

find_library(
  AppArmor_LIBRARY
  NAMES apparmor
  HINTS ${PC_AppArmor_LIBRARY_DIRS}
  DOC "The path to the AppArmor library"
)

if(NOT AppArmor_LIBRARY)
  string(APPEND _reason "AppArmor library not found. ")
endif()

# Sanity check.
if(AppArmor_INCLUDE_DIR AND AppArmor_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${AppArmor_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${AppArmor_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(aa_change_profile sys/apparmor.h _AppArmor_SANITY_CHECK)
  cmake_pop_check_state()
endif()

if(NOT _AppArmor_SANITY_CHECK)
  string(APPEND _reason "Sanity check failed: aa_change_profile not found. ")
endif()

# AppArmor headers don't provide version. Try pkg-config.
if(
  PC_AppArmor_VERSION
  AND AppArmor_INCLUDE_DIR IN_LIST PC_AppArmor_INCLUDE_DIRS
)
  set(AppArmor_VERSION ${PC_AppArmor_VERSION})
endif()

mark_as_advanced(AppArmor_INCLUDE_DIR AppArmor_LIBRARY)

find_package_handle_standard_args(
  AppArmor
  REQUIRED_VARS
    AppArmor_LIBRARY
    AppArmor_INCLUDE_DIR
    _AppArmor_SANITY_CHECK
  VERSION_VAR AppArmor_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT AppArmor_FOUND)
  return()
endif()

set(AppArmor_INCLUDE_DIRS ${AppArmor_INCLUDE_DIR})
set(AppArmor_LIBRARIES ${AppArmor_LIBRARY})

if(NOT TARGET AppArmor::AppArmor)
  if(IS_ABSOLUTE "${AppArmor_LIBRARY}")
    add_library(AppArmor::AppArmor UNKNOWN IMPORTED)
    set_target_properties(
      AppArmor::AppArmor
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${AppArmor_LIBRARY}"
    )
  else()
    add_library(AppArmor::AppArmor INTERFACE IMPORTED)
    set_target_properties(
      AppArmor::AppArmor
      PROPERTIES
        IMPORTED_LIBNAME "${AppArmor_LIBRARY}"
    )
  endif()

  set_target_properties(
    AppArmor::AppArmor
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${AppArmor_INCLUDE_DIRS}"
  )
endif()
