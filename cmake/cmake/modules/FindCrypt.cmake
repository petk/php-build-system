#[=============================================================================[
Find the crypt library and run a set of PHP-specific checks if library works.

The Crypt library can be on some systems part of the standard C library. The
crypt() and crypt_r() functions are usually declared in the unistd.h or crypt.h.
The GNU C library removed the crypt library in version 2.39 and replaced it with
the libxcrypt, at the time of writing, located at
https://github.com/besser82/libxcrypt.

Module defines the following `IMPORTED` target(s):

* `Crypt::Crypt` - The package library, if found.

Result variables:

* `Crypt_FOUND` - Whether the package has been found.
* `Crypt_INCLUDE_DIRS` - Include directories needed to use this package.
* `Crypt_LIBRARIES` - Libraries needed to link to the package library.
* `Crypt_VERSION` - Package version, if found.

Cache variables:

* `Crypt_IS_BUILT_IN` - Whether crypt is a part of the C library.
* `Crypt_INCLUDE_DIR` - Directory containing package library headers.
* `Crypt_LIBRARY` - The path to the package library.

Hints:

The `Crypt_ROOT` variable adds custom search path.
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Crypt
  PROPERTIES
    DESCRIPTION "Crypt library"
)

################################################################################
# Disable built-in Crypt when overriding search paths in FindCrypt.
################################################################################
if(CMAKE_PREFIX_PATH OR Crypt_ROOT)
  find_path(
    _Crypt_INCLUDE_DIR
    NAMES
      crypt.h unistd.h
    PATHS
      ${CMAKE_PREFIX_PATH}
      ${Crypt_ROOT}
    PATH_SUFFIXES
      include
    NO_DEFAULT_PATH
  )

  if(_Crypt_INCLUDE_DIR)
    set(Crypt_INCLUDE_DIR ${_Crypt_INCLUDE_DIR})
    set(Crypt_IS_BUILT_IN FALSE)
  endif()
endif()

set(_reason "")

# If no compiler is loaded C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(Crypt_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED Crypt_IS_BUILT_IN)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(crypt "unistd.h" Crypt_IS_BUILT_IN)
  cmake_pop_check_state()
endif()

set(_Crypt_REQUIRED_VARS)
if(Crypt_IS_BUILT_IN)
  set(_Crypt_REQUIRED_VARS _Crypt_IS_BUILT_IN_MSG)
  set(_Crypt_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_Crypt_REQUIRED_VARS Crypt_LIBRARY Crypt_INCLUDE_DIR _Crypt_SANITY_CHECK)

  # Use pkgconf, if available on the system.
  find_package(PkgConfig QUIET)
  if(PKG_CONFIG_FOUND)
    pkg_search_module(PC_Crypt QUIET libcrypt libxcrypt)
  endif()

  find_path(
    Crypt_INCLUDE_DIR
    NAMES crypt.h unistd.h
    HINTS ${PC_Crypt_INCLUDE_DIRS}
    DOC "Directory containing Crypt library headers"
  )

  if(NOT Crypt_INCLUDE_DIR)
    string(APPEND _reason "crypt.h not found. ")
  endif()

  find_library(
    Crypt_LIBRARY
    NAMES crypt
    HINTS ${PC_Crypt_LIBRARY_DIRS}
    DOC "The path to the crypt library"
  )

  if(NOT Crypt_LIBRARY)
    string(APPEND _reason "crypt library not found. ")
  endif()

  # Sanity check
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${Crypt_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${Crypt_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(crypt "unistd.h" _Crypt_SANITY_CHECK)
  cmake_pop_check_state()

  mark_as_advanced(Crypt_INCLUDE_DIR Crypt_LIBRARY)
endif()

# Get version.
block(PROPAGATE Crypt_VERSION)
  if(Crypt_INCLUDE_DIR AND EXISTS ${Crypt_INCLUDE_DIR}/crypt.h)
    set(regex [[^[ \t]*#[ \t]*define[ \t]+XCRYPT_VERSION_STR[ \t]+"?([0-9.]+)"?[ \t]*$]])

    file(STRINGS ${Crypt_INCLUDE_DIR}/crypt.h results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(Crypt_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()

  if(NOT Crypt_VERSION AND PC_Crypt_VERSION)
    cmake_path(
      COMPARE
      "${PC_Crypt_INCLUDEDIR}" EQUAL "${Crypt_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(Crypt_VERSION ${PC_Crypt_VERSION})
    endif()
  endif()
endblock()

################################################################################
# Handle find_package arguments.
################################################################################

find_package_handle_standard_args(
  Crypt
  REQUIRED_VARS
    ${_Crypt_REQUIRED_VARS}
  VERSION_VAR Crypt_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_Crypt_REQUIRED_VARS)
unset(_Crypt_IS_BUILT_IN_MSG)

if(NOT Crypt_FOUND)
  return()
endif()

if(Crypt_IS_BUILT_IN)
  set(Crypt_INCLUDE_DIRS "")
  set(Crypt_LIBRARIES "")
else()
  set(Crypt_INCLUDE_DIRS ${Crypt_INCLUDE_DIR})
  set(Crypt_LIBRARIES ${Crypt_LIBRARY})
endif()

if(NOT TARGET Crypt::Crypt)
  add_library(Crypt::Crypt UNKNOWN IMPORTED)

  if(Crypt_INCLUDE_DIR)
    set_target_properties(
      Crypt::Crypt
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Crypt_INCLUDE_DIR}"
    )
  endif()

  if(Crypt_LIBRARY)
    set_target_properties(
      Crypt::Crypt
      PROPERTIES
        IMPORTED_LOCATION "${Crypt_LIBRARY}"
    )
  endif()
endif()
