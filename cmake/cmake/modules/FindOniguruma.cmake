#[=============================================================================[
Find the Oniguruma library.
https://github.com/kkos/oniguruma

Module defines the following IMPORTED targets:

  Oniguruma::Oniguruma
    The Oniguruma library, if found.

Result variables:

  Oniguruma_FOUND
    Set to 1 if Oniguruma library is found.
  Oniguruma_INCLUDE_DIRS
    A list of include directories for using Oniguruma library.
  Oniguruma_LIBRARIES
    A list of libraries for using Oniguruma library.
  Oniguruma_VERSION
    Version string of found Oniguruma library.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

find_path(Oniguruma_INCLUDE_DIRS NAMES oniguruma.h)
find_library(Oniguruma_LIBRARIES NAMES onig)

if(EXISTS "${Oniguruma_INCLUDE_DIRS}/oniguruma.h")
  set(_oniguruma_h "${Oniguruma_INCLUDE_DIRS}/oniguruma.h")
endif()

if(Oniguruma_INCLUDE_DIRS AND _oniguruma_h)
  file(
    STRINGS
    "${_oniguruma_h}"
    _oniguruma_version_string
    REGEX
    "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_(MAJOR|MINOR|TEENY)[ \t]+[0-9]+[ \t]*$"
  )

  unset(Oniguruma_VERSION)

  foreach(version_part MAJOR MINOR TEENY)
    foreach(version_line ${_oniguruma_version_string})
      set(
        _oniguruma_regex
        "^#[ \t]*define[ \t]+ONIGURUMA_VERSION_${version_part}[ \t]+([0-9]+)[ \t]*$"
      )

      if(version_line MATCHES "${_oniguruma_regex}")
        set(_oniguruma_version_part "${CMAKE_MATCH_1}")
        if(Oniguruma_VERSION)
          string(APPEND Oniguruma_VERSION ".${_oniguruma_version_part}")
        else()
          set(Oniguruma_VERSION "${_oniguruma_version_part}")
        endif()
        unset(_oniguruma_version_part)
      endif()
    endforeach()
  endforeach()

  unset(_oniguruma_h)
  unset(_oniguruma_version_string)
endif()

find_package_handle_standard_args(
  Oniguruma
  REQUIRED_VARS Oniguruma_LIBRARIES
  VERSION_VAR Oniguruma_VERSION
  REASON_FAILURE_MESSAGE "Oniguruma not found. Please install Oniguruma library (libonig)."
)

mark_as_advanced(Oniguruma_INCLUDE_DIRS Oniguruma_LIBRARIES)

if(Oniguruma_FOUND AND NOT TARGET Oniguruma::Oniguruma)
  add_library(Oniguruma::Oniguruma INTERFACE IMPORTED)

  set_target_properties(Oniguruma::Oniguruma PROPERTIES
    INTERFACE_LINK_LIBRARIES "${Oniguruma_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${Oniguruma_INCLUDE_DIRS}"
  )
endif()
