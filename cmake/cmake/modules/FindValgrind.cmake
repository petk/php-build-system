#[=============================================================================[
# FindValgrind

Find Valgrind.

Module defines the following `IMPORTED` target(s):

* `Valgrind::Valgrind` - The package library, if found.

## Result variables

* `Valgrind_FOUND` - Whether the package has been found.
* `Valgrind_INCLUDE_DIRS` - Include directories needed to use this package.

## Cache variables

* `Valgrind_INCLUDE_DIR` - Directory containing package library headers.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Valgrind
  PROPERTIES
    URL "https://valgrind.org/"
    DESCRIPTION "Instrumentation framework for building dynamic analysis tools"
    PURPOSE "Detects memory management and threading bugs"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Valgrind QUIET valgrind)

  # At the time of writing, valgrind.pc sets includedir, for example, as
  # "/usr/include/valgrind" instead of its parent. Either valgrind.pc CFLAGS
  # need to be fixed upstream or valgrind.h usage in the code
  # (#include <valgrind.h> vs. #include <valgrind/valgrind.h>). Here, parent
  # directory is appended to the include directories and header is searched as
  # valgrind/valgrind.h as included in PHP.
  if(PC_Valgrind_FOUND AND PC_Valgrind_INCLUDEDIR MATCHES "valgrind$")
    cmake_path(GET PC_Valgrind_INCLUDEDIR PARENT_PATH _valgrind_parent_include)
    if(NOT _valgrind_parent_include IN_LIST PC_Valgrind_INCLUDE_DIRS)
      list(APPEND PC_Valgrind_INCLUDE_DIRS ${_valgrind_parent_include})
    endif()
    unset(_valgrind_parent_include)
  endif()
endif()

find_path(
  Valgrind_INCLUDE_DIR
  NAMES valgrind/valgrind.h
  HINTS ${PC_Valgrind_INCLUDE_DIRS}
  DOC "Directory containing Valgrind library headers"
)

if(NOT Valgrind_INCLUDE_DIR)
  string(APPEND _reason "valgrind/valgrind.h not found. ")
endif()

block(PROPAGATE Valgrind_VERSION)
  if(EXISTS ${Valgrind_INCLUDE_DIR}/valgrind/config.h)
    set(regex "^[ \t]*#[ \t]*define[ \t]+VERSION[ \t]+\"?([^\"]+)\"?[ \t]*$")

    file(STRINGS ${Valgrind_INCLUDE_DIR}/valgrind/config.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(Valgrind_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT Valgrind_VERSION
    AND PC_Valgrind_VERSION
    AND Valgrind_INCLUDE_DIR IN_LIST PC_Valgrind_INCLUDE_DIRS
  )
    set(Valgrind_VERSION ${PC_Valgrind_VERSION})
  endif()
endblock()

mark_as_advanced(Valgrind_INCLUDE_DIR)

find_package_handle_standard_args(
  Valgrind
  REQUIRED_VARS
    Valgrind_INCLUDE_DIR
  VERSION_VAR Valgrind_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Valgrind_FOUND)
  return()
endif()

set(
  Valgrind_INCLUDE_DIRS
  ${Valgrind_INCLUDE_DIR}
  ${Valgrind_INCLUDE_DIR}/valgrind # See above note about the parent includedir.
)

if(NOT TARGET Valgrind::Valgrind)
  add_library(Valgrind::Valgrind INTERFACE IMPORTED)

  set_target_properties(
    Valgrind::Valgrind
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Valgrind_INCLUDE_DIRS}"
  )
endif()
