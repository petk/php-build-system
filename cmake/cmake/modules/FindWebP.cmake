#[=============================================================================[
Find the libwebp library.

Module defines the following `IMPORTED` target(s):

* `WebP::WebP` - The package library, if found.

Result variables:

* `WebP_FOUND` - Whether the package has been found.
* `WebP_INCLUDE_DIRS` - Include directories needed to use this package.
* `WebP_LIBRARIES` - Libraries needed to link to the package library.
* `WebP_VERSION` - Package version, if found.

Cache variables:

* `WebP_INCLUDE_DIR` - Directory containing package library headers.
* `WebP_LIBRARY` - The path to the package library.

Hints:

The `WebP_ROOT` variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  WebP
  PROPERTIES
    URL "https://developers.google.com/speed/webp/"
    DESCRIPTION "Library for the WebP graphics format"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_WebP QUIET libwebp)
endif()

find_path(
  WebP_INCLUDE_DIR
  NAMES webp/decode.h
  PATHS ${PC_WebP_INCLUDE_DIRS}
  DOC "Directory containing libwebp library headers"
)

if(NOT WebP_INCLUDE_DIR)
  string(APPEND _reason "webp/decode.h not found. ")
endif()

find_library(
  WebP_LIBRARY
  NAMES webp
  PATHS ${PC_WebP_LIBRARY_DIRS}
  DOC "The path to the libwebp library"
)

if(NOT WebP_LIBRARY)
  string(APPEND _reason "WebP library not found. ")
endif()

# Get version.
block(PROPAGATE WebP_VERSION)
  # WebP headers don't provide version. Try pkgconf version, if found.
  if(PC_WebP_VERSION)
    cmake_path(
      COMPARE
      "${PC_WebP_INCLUDEDIR}" EQUAL "${WebP_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(WebP_VERSION ${PC_WebP_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(WebP_INCLUDE_DIR WebP_LIBRARY)

find_package_handle_standard_args(
  WebP
  REQUIRED_VARS
    WebP_LIBRARY
    WebP_INCLUDE_DIR
  VERSION_VAR WebP_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT WebP_FOUND)
  return()
endif()

set(WebP_INCLUDE_DIRS ${WebP_INCLUDE_DIR})
set(WebP_LIBRARIES ${WebP_LIBRARY})

if(NOT TARGET WebP::WebP)
  add_library(WebP::WebP UNKNOWN IMPORTED)

  set_target_properties(
    WebP::WebP
    PROPERTIES
      IMPORTED_LOCATION "${WebP_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${WebP_INCLUDE_DIR}"
  )
endif()
