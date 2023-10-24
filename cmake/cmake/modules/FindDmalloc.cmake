#[=============================================================================[
Find the Dmalloc library (Debug Malloc Library).
https://dmalloc.com/

Module defines the following IMPORTED targets:

  Dmalloc::Dmalloc
    The Dmalloc library, if found.

Result variables:

  Dmalloc_FOUND
    Set to 1 if Dmalloc library is found.
  Dmalloc_INCLUDE_DIRS
    A list of include directories for using Dmalloc library.
  Dmalloc_LIBRARIES
    A list of libraries for using Dmalloc library.
  Dmalloc_VERSION
    Version string of found Dmalloc library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_path(Dmalloc_INCLUDE_DIRS dmalloc.h)

find_library(Dmalloc_LIBRARIES NAMES dmalloc DOC "The Dmalloc library")

if(EXISTS "${Dmalloc_INCLUDE_DIRS}/dmalloc.h")
  set(_dmalloc_h "${Dmalloc_INCLUDE_DIRS}/dmalloc.h")
endif()

if(Dmalloc_INCLUDE_DIRS AND _dmalloc_h)
  file(
    STRINGS
    "${_dmalloc_h}"
    _dmalloc_version_string
    REGEX
    "^#[ \t]*define[ \t]+DMALLOC_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*[^\r\n]*$"
  )

  unset(Dmalloc_VERSION)

  foreach(version_part MAJOR MINOR PATCH)
    foreach(version_line ${_dmalloc_version_string})
      set(
        _dmalloc_regex
        "^#[ \t]*define[ \t]+DMALLOC_VERSION_${version_part}[ \t]+([0-9]+)[ \t]*[^\r\n]*$"
      )

      if(version_line MATCHES "${_dmalloc_regex}")
        set(_dmalloc_version_part "${CMAKE_MATCH_1}")

        if(Dmalloc_VERSION)
          string(APPEND Dmalloc_VERSION ".${_dmalloc_version_part}")
        else()
          set(Dmalloc_VERSION "${_dmalloc_version_part}")
        endif()

        unset(_dmalloc_version_part)
      endif()
    endforeach()
  endforeach()

  unset(_dmalloc_h)
  unset(_dmalloc_version_string)
endif()

find_package_handle_standard_args(
  Dmalloc
  REQUIRED_VARS Dmalloc_LIBRARIES Dmalloc_INCLUDE_DIRS
  VERSION_VAR Dmalloc_VERSION
  REASON_FAILURE_MESSAGE "Dmalloc library not found. Please install the Dmalloc library."
)

if(Dmalloc_FOUND AND NOT TARGET Dmalloc::Dmalloc)
  add_library(Dmalloc::Dmalloc INTERFACE IMPORTED)

  set_target_properties(Dmalloc::Dmalloc PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Dmalloc_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Dmalloc_INCLUDE_DIRS}"
  )
endif()
