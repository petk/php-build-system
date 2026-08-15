#[=============================================================================[
# FindImagequant

Finds the Imagequant library (libimagequant):

```cmake
find_package(Imagequant [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `Imagequant::Imagequant` - Target encapsulating the package usage
  requirements, available if package was found.

## Result variables

This module defines the following variables:

* `Imagequant_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `Imagequant_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Imagequant_INCLUDE_DIR` - Directory containing package library headers.
* `Imagequant_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Imagequant)
target_link_libraries(example PRIVATE Imagequant::Imagequant)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Imagequant
  PROPERTIES
    URL "https://pngquant.org/lib/"
    DESCRIPTION
      "Library for converting RGBA images to 8-bit indexed-color images"
)

block(PROPAGATE Imagequant_FOUND Imagequant_VERSION)
  set(reason "")

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
    pkg_check_modules(PC_Imagequant QUIET imagequant)
  endif()

  find_path(
    Imagequant_INCLUDE_DIR
    NAMES libimagequant.h
    HINTS ${PC_Imagequant_INCLUDE_DIRS}
    DOC "Directory containing Imagequant library headers"
  )
  mark_as_advanced(Imagequant_INCLUDE_DIR)

  if(NOT Imagequant_INCLUDE_DIR)
    string(APPEND reason "<libimagequant.h> not found. ")
  endif()

  find_library(
    Imagequant_LIBRARY
    NAMES imagequant
    HINTS ${PC_Imagequant_LIBRARY_DIRS}
    DOC "The path to the Imagequant library"
  )
  mark_as_advanced(Imagequant_LIBRARY)

  if(NOT Imagequant_LIBRARY)
    string(APPEND reason "Imagequant library not found. ")
  endif()

  # Get version (version is available in libimagequant.h since 2.3.1).
  if(Imagequant_INCLUDE_DIR)
    set(
      regex
      "^#[ \t]*define[ \t]+LIQ_VERSION_STRING[ \t]+\"([0-9.]+)\"[ \t]*$"
    )

    file(
      STRINGS ${Imagequant_INCLUDE_DIR}/libimagequant.h
      result
      REGEX "${regex}"
    )

    unset(Imagequant_VERSION)

    if(result MATCHES "${regex}")
      set(Imagequant_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT Imagequant_VERSION
    AND PC_Imagequant_VERSION
    AND Imagequant_INCLUDE_DIR IN_LIST PC_Imagequant_INCLUDE_DIRS
  )
    set(Imagequant_VERSION ${PC_Imagequant_VERSION})
  endif()

  # Heuristic version determination.
  if(NOT Imagequant_VERSION AND Imagequant_INCLUDE_DIR AND Imagequant_LIBRARY)
    cmake_push_check_state(RESET)

    set(CMAKE_REQUIRED_INCLUDES ${Imagequant_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${Imagequant_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    # liq_attr_create() was added in version libimagequant 2.0.0.
    check_symbol_exists(
      liq_attr_create
      libimagequant.h
      Imagequant_HAS_LIQ_ATTR_CREATE
    )

    cmake_pop_check_state()

    if(Imagequant_HAS_LIQ_ATTR_CREATE)
      set(Imagequant_VERSION 2.0)
      message(
        WARNING
        "The found Imagequant version was determined heuristically"
      )
    endif()
  endif()

  find_package_handle_standard_args(
    Imagequant
    REQUIRED_VARS Imagequant_LIBRARY Imagequant_INCLUDE_DIR
    VERSION_VAR Imagequant_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )

  if(NOT Imagequant_FOUND)
    return()
  endif()

  if(NOT TARGET Imagequant::Imagequant)
    add_library(Imagequant::Imagequant UNKNOWN IMPORTED)

    set_target_properties(
      Imagequant::Imagequant
      PROPERTIES
        IMPORTED_LOCATION "${Imagequant_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Imagequant_INCLUDE_DIR}"
    )
  endif()
endblock()
