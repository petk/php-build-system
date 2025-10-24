#[=============================================================================[
# FindCrypt

Finds the crypt library and run a set of PHP-specific checks if library works:

```cmake
find_package(Crypt [<version>] [...])
```

The Crypt library can be on some systems part of the standard C library. The
crypt() and crypt_r() functions are usually declared in the unistd.h or crypt.h.
The GNU C library removed the crypt library in version 2.39 and replaced it with
the libxcrypt, at the time of writing, located at
https://github.com/besser82/libxcrypt.

## Imported targets

This module provides the following imported targets:

* `Crypt::Crypt` - The package library, if found.

## Result variables

This module defines the following variables:

* `Crypt_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `Crypt_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Crypt_IS_BUILT_IN` - Whether crypt is a part of the C library.
* `Crypt_INCLUDE_DIR` - Directory containing package library headers.
* `Crypt_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Crypt)
target_link_libraries(example PRIVATE Crypt::Crypt)
```
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

# Disable searching for built-in crypt when overriding search paths.
if(
  NOT DEFINED Crypt_IS_BUILT_IN
  AND NOT DEFINED Crypt_INCLUDE_DIR
  AND NOT DEFINED Crypt_LIBRARY
  AND (
    CMAKE_PREFIX_PATH
    OR Crypt_ROOT
    OR CRYPT_ROOT
    OR DEFINED ENV{Crypt_ROOT}
    OR DEFINED ENV{CRYPT_ROOT}
  )
)
  find_path(
    Crypt_INCLUDE_DIR
    NAMES crypt.h unistd.h
    DOC "Directory containing Crypt library headers"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  find_library(
    Crypt_LIBRARY
    NAMES crypt
    DOC "The path to the crypt library"
    NO_CMAKE_ENVIRONMENT_PATH
    NO_SYSTEM_ENVIRONMENT_PATH
    NO_CMAKE_INSTALL_PREFIX
    NO_CMAKE_SYSTEM_PATH
  )

  if(Crypt_INCLUDE_DIR AND Crypt_LIBRARY)
    set(Crypt_IS_BUILT_IN FALSE)
  else()
    unset(CACHE{Crypt_INCLUDE_DIR})
    unset(CACHE{Crypt_LIBRARY})
  endif()
endif()

set(_reason "")
set(_Crypt_REQUIRED_VARS "")

# If no compiler is loaded C library can't be checked anyway.
if(NOT CMAKE_C_COMPILER_LOADED AND NOT CMAKE_CXX_COMPILER_LOADED)
  set(Crypt_IS_BUILT_IN FALSE)
endif()

if(NOT DEFINED Crypt_IS_BUILT_IN)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(crypt unistd.h Crypt_IS_BUILT_IN)
  cmake_pop_check_state()
endif()

if(Crypt_IS_BUILT_IN)
  set(_Crypt_REQUIRED_VARS _Crypt_IS_BUILT_IN_MSG)
  set(_Crypt_IS_BUILT_IN_MSG "built in to C library")
else()
  set(_Crypt_REQUIRED_VARS Crypt_LIBRARY Crypt_INCLUDE_DIR Crypt_SANITY_CHECK)

  find_package(PkgConfig QUIET)
  if(PkgConfig_FOUND)
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
    check_symbol_exists(crypt unistd.h Crypt_SANITY_CHECK)
  cmake_pop_check_state()

  mark_as_advanced(Crypt_INCLUDE_DIR Crypt_LIBRARY)
endif()

# Get version.
block(PROPAGATE Crypt_VERSION)
  if(EXISTS ${Crypt_INCLUDE_DIR}/crypt.h)
    set(regex "^[ \t]*#[ \t]*define[ \t]+XCRYPT_VERSION_STR[ \t]+\"?([^\"]+)\"?[ \t]*$")

    file(STRINGS ${Crypt_INCLUDE_DIR}/crypt.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(Crypt_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT Crypt_VERSION
    AND PC_Crypt_VERSION
    AND Crypt_INCLUDE_DIR IN_LIST PC_Crypt_INCLUDE_DIRS
  )
    set(Crypt_VERSION ${PC_Crypt_VERSION})
  endif()
endblock()

find_package_handle_standard_args(
  Crypt
  REQUIRED_VARS ${_Crypt_REQUIRED_VARS}
  VERSION_VAR Crypt_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_Crypt_IS_BUILT_IN_MSG)
unset(_Crypt_REQUIRED_VARS)

if(NOT Crypt_FOUND)
  return()
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
