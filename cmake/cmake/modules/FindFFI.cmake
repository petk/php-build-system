#[=============================================================================[
Find the FFI library.

Module defines the following IMPORTED targets:

  FFI::FFI
    The FFI library, if found.

Result variables:

  FFI_FOUND
    Whether FFI library is found.
  FFI_INCLUDE_DIRS
    A list of include directories for using FFI library.
  FFI_LIBRARIES
    A list of libraries to link when using FFI library.
  FFI_VERSION
    Version string of found FFI library.

Hints:

  The FFI_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(FFI PROPERTIES
  URL "https://sourceware.org/libffi/"
  DESCRIPTION "Foreign Function Interfaces library"
)

set(_reason_failure_message)

find_path(FFI_INCLUDE_DIRS ffi.h)

if(NOT FFI_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    ffi.h not found."
  )
endif()

find_library(FFI_LIBRARIES NAMES ffi DOC "The FFI library")

if(NOT FFI_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    FFI not found. Please install the FFI library (libffi)."
  )
endif()

block(PROPAGATE FFI_VERSION)
  if(FFI_INCLUDE_DIRS)
    file(
      STRINGS
      "${FFI_INCLUDE_DIRS}/ffi.h"
      strings
      REGEX
      "^[ \t]*libffi[ \t]+[0-9.]+[ \t]*$"
    )

    foreach(line ${strings})
      if(line MATCHES "^[ \t]*libffi[ \t]+([0-9.]+)[ \t]*$")
        set(FFI_VERSION "${CMAKE_MATCH_1}")
      endif()
    endforeach()
  endif()
endblock()

if(FFI_VERSION)
  set(_ffi_version_argument VERSION_VAR FFI_VERSION)
endif()

find_package_handle_standard_args(
  FFI
  REQUIRED_VARS FFI_LIBRARIES FFI_INCLUDE_DIRS
  ${_ffi_version_argument}
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)
unset(_ffi_version_argument)

if(FFI_FOUND AND NOT TARGET FFI::FFI)
  add_library(FFI::FFI INTERFACE IMPORTED)

  set_target_properties(FFI::FFI PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${FFI_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${FFI_LIBRARIES}"
  )
endif()
