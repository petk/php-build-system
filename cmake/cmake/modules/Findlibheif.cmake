#[=============================================================================[
# Findlibheif

Finds the libheif library:

```cmake
find_package(libheif [<version>] [...])
```

This is a helper find module because the libheif upstream CMake config files
have `ExactVersion` compatibility constraint which isn't useful for finding any
libheif version.

## Imported targets

This module provides the following imported targets:

* `libheif::libheif` - Target encapsulating the package usage requirements,
  available if package was found.

## Result variables

This module defines the following variables:

* `libheif_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `libheif_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `libheif_INCLUDE_DIR` - Directory containing package library headers.
* `libheif_LIBRARY` - The path to the package library.

## Hints

This module accepts the following variables before calling
`find_package(libheif)`:

* `libheif_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libheif)
target_link_libraries(example PRIVATE libheif::libheif)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  libheif
  PROPERTIES
    URL "https://github.com/strukturag/libheif"
    DESCRIPTION "HEIF and AVIF file format decoder and encoder library"
)

block(PROPAGATE libheif_FOUND libheif_VERSION)
  set(reason "")

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(PC_libheif QUIET libheif)
  endif()

  find_path(
    libheif_INCLUDE_DIR
    NAMES libheif/heif.h
    HINTS ${PC_libheif_INCLUDE_DIRS}
    DOC "Directory containing libheif library headers"
  )
  mark_as_advanced(libheif_INCLUDE_DIR)

  if(NOT libheif_INCLUDE_DIR)
    string(APPEND reason "<libheif/heif.h> not found. ")
  endif()

  find_library(
    libheif_LIBRARY
    NAMES heif
    HINTS ${PC_libheif_LIBRARY_DIRS}
    DOC "The path to the libheif library"
  )
  mark_as_advanced(libheif_LIBRARY)

  if(NOT libheif_LIBRARY)
    string(APPEND reason "libheif library not found. ")
  endif()

  # libheif provides version in a separate heif_version.h file which is
  # available at least as of libheif 1.0.0.
  if(EXISTS "${libheif_INCLUDE_DIR}/libheif/heif_version.h")
    set(regex "^#[ \t]*define[ \t]+LIBHEIF_VERSION[ \t]+\"([0-9.]+)\"[ \t]*$")

    file(
      STRINGS ${libheif_INCLUDE_DIR}/libheif/heif_version.h
      result
      REGEX "${regex}"
    )

    unset(libheif_VERSION)

    if(result MATCHES "${regex}")
      set(libheif_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT libheif_VERSION
    AND PC_libheif_VERSION
    AND libheif_INCLUDE_DIR IN_LIST PC_libheif_INCLUDE_DIRS
  )
    set(libheif_VERSION ${PC_libheif_VERSION})
  endif()

  find_package_handle_standard_args(
    libheif
    REQUIRED_VARS libheif_LIBRARY libheif_INCLUDE_DIR
    VERSION_VAR libheif_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )

  if(NOT libheif_FOUND)
    return()
  endif()

  if(NOT TARGET libheif::libheif)
    add_library(libheif::libheif UNKNOWN IMPORTED)

    set_target_properties(
      libheif::libheif
      PROPERTIES
        IMPORTED_LOCATION "${libheif_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${libheif_INCLUDE_DIR}"
    )

    if(WIN32 AND libheif_USE_STATIC_LIBS)
      set_target_properties(
        libheif::libheif
        PROPERTIES INTERFACE_COMPILE_DEFINITIONS "LIBHEIF_STATIC_BUILD"
      )
    endif()
  endif()
endblock()
