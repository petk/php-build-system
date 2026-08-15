#[=============================================================================[
# Findlibuhdr

Finds the libuhdr library:

```cmake
find_package(libuhdr [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `libuhdr::libuhdr` - Target encapsulating the package usage requirements,
  available if package was found.

## Result variables

This module defines the following variables:

* `libuhdr_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `libuhdr_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `libuhdr_INCLUDE_DIR` - Directory containing package library headers.
* `libuhdr_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(libuhdr)`:

* `libuhdr_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libuhdr)
target_link_libraries(example PRIVATE libuhdr::libuhdr)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  libuhdr
  PROPERTIES
    URL "https://github.com/google/libultrahdr"
    DESCRIPTION "Library for encoding and decoding ultrahdr images"
)

block(PROPAGATE libuhdr_FOUND libuhdr_VERSION)
  set(reason "")

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(PC_libuhdr QUIET libuhdr)
  endif()

  find_path(
    libuhdr_INCLUDE_DIR
    NAMES ultrahdr_api.h
    HINTS ${PC_libuhdr_INCLUDE_DIRS}
    DOC "Directory containing libuhdr library headers"
  )
  mark_as_advanced(libuhdr_INCLUDE_DIR)

  if(NOT libuhdr_INCLUDE_DIR)
    string(APPEND reason "<ultrahdr_api.h> not found. ")
  endif()

  find_library(
    libuhdr_LIBRARY
    NAMES uhdr
    HINTS ${PC_libuhdr_LIBRARY_DIRS}
    DOC "The path to the libuhdr library"
  )
  mark_as_advanced(libuhdr_LIBRARY)

  if(NOT libuhdr_LIBRARY)
    string(APPEND reason "libuhdr library not found. ")
  endif()

  # Get version.
  if(libuhdr_INCLUDE_DIR)
    file(
      STRINGS ${libuhdr_INCLUDE_DIR}/ultrahdr_api.h
      results
      REGEX
        "^#[ \t]*define[ \t]+UHDR_LIB_VER_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*$"
    )

    unset(libuhdr_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(
          line
            MATCHES
            "^#[ \t]*define[ \t]+UHDR_LIB_VER_${item}[ \t]+([0-9]+)[ \t]*$"
        )
          if(DEFINED libuhdr_VERSION)
            string(APPEND libuhdr_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(libuhdr_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()

  if(
    NOT libuhdr_VERSION
    AND PC_libuhdr_VERSION
    AND libuhdr_INCLUDE_DIR IN_LIST PC_libuhdr_INCLUDE_DIRS
  )
    set(libuhdr_VERSION ${PC_libuhdr_VERSION})
  endif()

  find_package_handle_standard_args(
    libuhdr
    REQUIRED_VARS libuhdr_LIBRARY libuhdr_INCLUDE_DIR
    VERSION_VAR libuhdr_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )

  if(NOT libuhdr_FOUND)
    return()
  endif()

  if(NOT TARGET libuhdr::libuhdr)
    add_library(libuhdr::libuhdr UNKNOWN IMPORTED)

    set_target_properties(
      libuhdr::libuhdr
      PROPERTIES
        IMPORTED_LOCATION "${libuhdr_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${libuhdr_INCLUDE_DIR}"
    )

    if(WIN32 AND NOT libuhdr_USE_STATIC_LIBS)
      set_target_properties(
        libuhdr::libuhdr
        PROPERTIES INTERFACE_COMPILE_DEFINITIONS "UHDR_USING_SHARED_LIBRARY"
      )
    endif()
  endif()
endblock()
