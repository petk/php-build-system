#[=============================================================================[
# FindTidy

Finds the Tidy library (tidy-html5, legacy htmltidy library, or the tidyp -
obsolete fork):

```cmake
find_package(Tidy [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Tidy::Tidy` - The package library, if found.

## Result variables

This module defines the following variables:

* `Tidy_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `Tidy_VERSION` - The version of package found.
* `Tidy_HEADER` - Name of the Tidy header (`tidy.h`, or `tidyp.h`).

## Cache variables

The following cache variables may also be set:

* `Tidy_INCLUDE_DIR` - Directory containing package library headers.
* `Tidy_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Tidy)
target_link_libraries(example PRIVATE Tidy::Tidy)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Tidy
  PROPERTIES
    URL "https://www.html-tidy.org/"
    DESCRIPTION "HTML syntax checker"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_Tidy QUIET tidy)
endif()

find_library(
  Tidy_LIBRARY
  NAMES
    tidy
    tidy5 # tidy-html5 on FreeBSD
    tidyp # Tidy library fork (obsolete)
  NAMES_PER_DIR
  HINTS ${PC_Tidy_LIBRARY_DIRS}
  DOC "The path to the Tidy library"
)

set(Tidy_HEADER "tidy.h")

if(NOT Tidy_LIBRARY)
  string(APPEND _reason "Tidy library not found. ")
else()
  cmake_path(GET Tidy_LIBRARY FILENAME name)
  if(name MATCHES "tidyp")
    set(Tidy_HEADER "tidyp.h")
  endif()
  unset(name)
endif()

find_path(
  Tidy_INCLUDE_DIR
  NAMES ${Tidy_HEADER}
  HINTS ${PC_Tidy_INCLUDE_DIRS}
  PATH_SUFFIXES
    tidy
    tidyp # Tidy library fork (obsolete).
  DOC "Directory containing Tidy library headers"
)

if(NOT Tidy_INCLUDE_DIR)
  string(APPEND _reason "${Tidy_HEADER} not found. ")
endif()

# Tidy headers don't provide version. Try pkg-config.
if(PC_Tidy_VERSION AND Tidy_INCLUDE_DIR IN_LIST PC_Tidy_INCLUDE_DIRS)
  set(Tidy_VERSION ${PC_Tidy_VERSION})
endif()

mark_as_advanced(Tidy_INCLUDE_DIR Tidy_LIBRARY)

find_package_handle_standard_args(
  Tidy
  REQUIRED_VARS
    Tidy_LIBRARY
    Tidy_INCLUDE_DIR
  VERSION_VAR Tidy_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Tidy_FOUND)
  return()
endif()

if(NOT TARGET Tidy::Tidy)
  add_library(Tidy::Tidy UNKNOWN IMPORTED)

  set_target_properties(
    Tidy::Tidy
    PROPERTIES
      IMPORTED_LOCATION "${Tidy_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Tidy_INCLUDE_DIR}"
  )
endif()
