#[=============================================================================[
Find the FFI library.

Module defines the following `IMPORTED` target(s):

* `FFI::FFI` - The package library, if found.

Result variables:

* `FFI_FOUND` - Whether the package has been found.
* `FFI_INCLUDE_DIRS` - Include directories needed to use this package.
* `FFI_LIBRARIES` - Libraries needed to link to the package library.
* `FFI_VERSION` - Package version, if found.

Cache variables:

* `FFI_INCLUDE_DIR` - Directory containing package library headers.
* `FFI_LIBRARY` - The path to the package library.

Hints:

The `FFI_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  FFI
  PROPERTIES
    URL "https://sourceware.org/libffi/"
    DESCRIPTION "Foreign Function Interfaces library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_FFI QUIET libffi)
endif()

find_path(
  FFI_INCLUDE_DIR
  NAMES ffi.h
  HINTS ${PC_FFI_INCLUDE_DIRS}
  DOC "Directory containing FFI library headers"
)

if(NOT FFI_INCLUDE_DIR)
  string(APPEND _reason "ffi.h not found. ")
endif()

find_library(
  FFI_LIBRARY
  NAMES ffi
  HINTS ${PC_FFI_LIBRARY_DIRS}
  DOC "The path to the FFI library"
)

if(NOT FFI_LIBRARY)
  string(APPEND _reason "FFI library (libffi) not found. ")
endif()

block(PROPAGATE FFI_VERSION)
  if(FFI_INCLUDE_DIR)
    set(regex [[^[ \t]*libffi[ \t]+([0-9.]+)[ \t]*$]])
    file(STRINGS ${FFI_INCLUDE_DIR}/ffi.h results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(FFI_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()

  # Version was not found in the header. Try pkgconf, if found.
  if(NOT FFI_VERSION AND PC_FFI_VERSION)
    cmake_path(COMPARE "${PC_FFI_INCLUDEDIR}" EQUAL "${FFI_INCLUDE_DIR}" isEqual)

    if(isEqual)
      set(FFI_VERSION ${PC_FFI_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(FFI_INCLUDE_DIR FFI_LIBRARY)

find_package_handle_standard_args(
  FFI
  REQUIRED_VARS
    FFI_LIBRARY
    FFI_INCLUDE_DIR
  VERSION_VAR FFI_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT FFI_FOUND)
  return()
endif()

set(FFI_INCLUDE_DIRS ${FFI_INCLUDE_DIR})
set(FFI_LIBRARIES ${FFI_LIBRARY})

if(NOT TARGET FFI::FFI)
  add_library(FFI::FFI UNKNOWN IMPORTED)

  set_target_properties(
    FFI::FFI
    PROPERTIES
      IMPORTED_LOCATION "${FFI_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${FFI_INCLUDE_DIR}"
  )
endif()
