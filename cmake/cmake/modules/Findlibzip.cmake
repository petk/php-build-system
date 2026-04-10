#[=============================================================================[
# Findlibzip

Finds the libzip library:

```cmake
find_package(libzip [<version>] [...])
```

This module is provided in case the system doesn't have the libzip's CMake
config file installation yet. It seems that libzip config files provided by the
library require also zip tools installed on the system, which is not required to
use only the libzip library.

## Imported targets

This module provides the following imported targets:

* `libzip::zip` - Target encapsulating the package usage requirements, available
  if package was found.

## Result variables

This module defines the following variables:

* `libzip_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `libzip_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(libzip)`:

* `libzip_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

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

block(
  PROPAGATE
    libzip_FOUND
    libzip_VERSION
)
  set(reason "")

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
  mark_as_advanced(libzip_INCLUDE_DIR)

  if(NOT libzip_INCLUDE_DIR)
    string(APPEND reason "<zip.h> not found. ")
  endif()

  # Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
  if(libzip_USE_STATIC_LIBS)
    if(WIN32)
      list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
    else()
      set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    endif()

    set(
      libzip_names
      zip # Unix-like systems.
      zip_a # https://github.com/winlibs/libzip
    )
  else()
    set(libzip_names zip)
  endif()

  find_library(
    libzip_LIBRARY
    NAMES ${libzip_names}
    NAMES_PER_DIR
    HINTS ${PC_libzip_LIBRARY_DIRS}
    DOC "The path to the libzip library"
  )
  mark_as_advanced(libzip_LIBRARY)

  if(NOT libzip_LIBRARY)
    string(APPEND reason "libzip library not found. ")
  endif()

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

  find_package_handle_standard_args(
    libzip
    REQUIRED_VARS
      libzip_LIBRARY
      libzip_INCLUDE_DIR
    VERSION_VAR libzip_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )

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

    # ZIP_STATIC needs to be defined when using static libzip version 1.0.0 to
    # 1.3.2.
    if(
      libzip_USE_STATIC_LIBS
      AND CMAKE_SYSTEM_NAME STREQUAL "Windows"
      AND libzip_VERSION VERSION_GREATER_EQUAL 1.0.0
      AND libzip_VERSION VERSION_LESS 1.4.0
    )
      set_target_properties(
        libzip::zip
        PROPERTIES
          INTERFACE_COMPILE_DEFINITIONS "ZIP_STATIC"
      )
    endif()

    # TODO: When using static library, also dependencies must be linked.
    if(libzip_USE_STATIC_LIBS)
      #set_target_properties(libzip::zip PROPERTIES INTERFACE_LINK_LIBRARIES "")
    endif()
  endif()
endblock()
