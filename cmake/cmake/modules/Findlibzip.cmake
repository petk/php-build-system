#[=============================================================================[
# Findlibzip

Finds the libzip library:

```cmake
find_package(libzip [<version>] [...])
```

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

## Imported targets

This module defines the following imported targets:

* `libzip::zip` - The package library, if found.

## Result variables

* `libzip_FOUND` - Boolean indicating whether the package is found.
* `libzip_VERSION` - The version of package found.

## Cache variables

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libzip)
target_link_libraries(example PRIVATE libzip::zip)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  libzip
  PROPERTIES
    URL "https://libzip.org/"
    DESCRIPTION "Library for handling ZIP archives"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_libzip QUIET libzip)
endif()

find_path(
  libzip_INCLUDE_DIR
  NAMES zip.h
  HINTS ${PC_libzip_INCLUDE_DIRS}
  DOC "Directory containing libzip library headers"
)

if(NOT libzip_INCLUDE_DIR)
  string(APPEND _reason "zip.h not found. ")
endif()

find_library(
  libzip_LIBRARY
  NAMES zip
  HINTS ${PC_libzip_LIBRARY_DIRS}
  DOC "The path to the libzip library"
)

if(NOT libzip_LIBRARY)
  string(APPEND _reason "libzip library not found. ")
endif()

block(PROPAGATE libzip_VERSION)
  if(EXISTS ${libzip_INCLUDE_DIR}/zipconf.h)
    file(
      STRINGS
      ${libzip_INCLUDE_DIR}/zipconf.h
      _
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+LIBZIP_VERSION[ \t]+\"?([^\"]+)\"?[ \t]*$"
    )
    set(libzip_VERSION "${CMAKE_MATCH_1}")
  endif()

  if(
    NOT libzip_VERSION
    AND PC_libzip_VERSION
    AND libzip_INCLUDE_DIR IN_LIST PC_libzip_INCLUDE_DIRS
  )
    set(libzip_VERSION ${PC_libzip_VERSION})
  endif()
endblock()

mark_as_advanced(libzip_INCLUDE_DIR libzip_LIBRARY)

find_package_handle_standard_args(
  libzip
  REQUIRED_VARS
    libzip_LIBRARY
    libzip_INCLUDE_DIR
  VERSION_VAR libzip_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT libzip_FOUND)
  return()
endif()

if(NOT TARGET libzip::zip)
  add_library(libzip::zip UNKNOWN IMPORTED)

  set_target_properties(
    libzip::zip
    PROPERTIES
      IMPORTED_LOCATION "${libzip_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${libzip_INCLUDE_DIR}"
  )
endif()
