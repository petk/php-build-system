#[=============================================================================[
# FindArgon2

Finds the Argon2 library:

```cmake
find_package(Argon2)
```

## Imported targets

This module defines the following imported targets:

* `Argon2::Argon2` - The package library, if found.

## Result variables

* `Argon2_FOUND` - Whether the package has been found.
* `Argon2_INCLUDE_DIRS` - Include directories needed to use this package.
* `Argon2_LIBRARIES` - Libraries needed to link to the package library.
* `Argon2_VERSION` - Package version, if found.

## Cache variables

* `Argon2_INCLUDE_DIR` - Directory containing package library headers.
* `Argon2_LIBRARY` - The path to the package library.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Argon2)
target_link_libraries(example PRIVATE Argon2::Argon2)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Argon2
  PROPERTIES
    URL "https://github.com/P-H-C/phc-winner-argon2/"
    DESCRIPTION "The password hash Argon2 library"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Argon2 QUIET libargon2)
endif()

find_path(
  Argon2_INCLUDE_DIR
  NAMES argon2.h
  HINTS ${PC_Argon2_INCLUDE_DIRS}
  DOC "Directory containing Argon2 library headers"
)

if(NOT Argon2_INCLUDE_DIR)
  string(APPEND _reason "argon2.h not found. ")
endif()

find_library(
  Argon2_LIBRARY
  NAMES argon2
  HINTS ${PC_Argon2_LIBRARY_DIRS}
  DOC "The path to the Argon2 library"
)

if(NOT Argon2_LIBRARY)
  string(APPEND _reason "Argon2 library (libargon2) not found. ")
endif()

# Argon2 headers don't provide version. Try pkg-config, or fallback to
# heuristic version determination.
if(PC_Argon2_VERSION AND Argon2_INCLUDE_DIR IN_LIST PC_Argon2_INCLUDE_DIRS)
  set(Argon2_VERSION ${PC_Argon2_VERSION})
elseif(Argon2_LIBRARY AND Argon2_INCLUDE_DIR)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES "${Argon2_LIBRARY}")
    set(CMAKE_REQUIRED_INCLUDES "${Argon2_INCLUDE_DIR}")
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(error_message argon2.h _Argon2_HAVE_ERROR_MESSAGE)

    if(_Argon2_HAVE_ERROR_MESSAGE)
      set(Argon2_VERSION 20151206)
    else()
      check_symbol_exists(
        ARGON2_FLAG_CLEAR_MEMORY
        argon2.h
        _Argon2_HAVE_ARGON2_FLAG_CLEAR_MEMORY
      )
    endif()

    if(_Argon2_HAVE_ARGON2_FLAG_CLEAR_MEMORY)
      set(Argon2_VERSION 20160406)
    else()
      check_symbol_exists(argon2id_hash_raw argon2.h _Argon2_HAVE_ARGON2ID_HASH_RAW)
    endif()

    if(_Argon2_HAVE_ARGON2ID_HASH_RAW)
      set(Argon2_VERSION 20161029)
    endif()

    check_symbol_exists(ARGON2_LOCAL argon2.h _Argon2_HAVE_ARGON2_LOCAL)
    if(_Argon2_HAVE_ARGON2_LOCAL)
      set(Argon2_VERSION 20171227)

      file(STRINGS ${Argon2_INCLUDE_DIR}/argon2.h content REGEX " deafults ")

      if(NOT content)
        set(Argon2_VERSION 20190702)
      endif()
      unset(content)
    endif()
  cmake_pop_check_state()
endif()

mark_as_advanced(Argon2_INCLUDE_DIR Argon2_LIBRARY)

find_package_handle_standard_args(
  Argon2
  REQUIRED_VARS
    Argon2_LIBRARY
    Argon2_INCLUDE_DIR
  VERSION_VAR Argon2_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Argon2_FOUND)
  return()
endif()

set(Argon2_INCLUDE_DIRS ${Argon2_INCLUDE_DIR})
set(Argon2_LIBRARIES ${Argon2_LIBRARY})

if(NOT TARGET Argon2::Argon2)
  if(IS_ABSOLUTE "${Argon2_LIBRARY}")
    add_library(Argon2::Argon2 UNKNOWN IMPORTED)
    set_target_properties(
      Argon2::Argon2
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${Argon2_LIBRARY}"
    )
  else()
    add_library(Argon2::Argon2 INTERFACE IMPORTED)
    set_target_properties(
      Argon2::Argon2
      PROPERTIES
        IMPORTED_LIBNAME "${Argon2_LIBRARY}"
    )
  endif()

  set_target_properties(
    Argon2::Argon2
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Argon2_INCLUDE_DIRS}"
  )
endif()
