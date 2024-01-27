#[=============================================================================[
Find Valgrind.

Module defines the following IMPORTED target(s):

  Valgrind::Valgrind
    The package library, if found.

Result variables:

  Valgrind_FOUND
    Whether the package has been found.
  Valgrind_INCLUDE_DIRS
    Include directories needed to use this package.

Cache variables:

  Valgrind_INCLUDE_DIR
    Directory containing package library headers.
  HAVE_VALGRIND
    Whether Valgrind is enabled.

Hints:

  The Valgrind_ROOT variable adds custom search path.
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

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Valgrind QUIET valgrind)

find_path(
  Valgrind_INCLUDE_DIR
  NAMES valgrind/valgrind.h
  # TODO: pkgconf returns "/usr/include/valgrind" instead of its parent. Either
  # pkgconf setting needs to be fixed upstream or its usage in the code.
  PATHS ${PC_Valgrind_INCLUDE_DIRS}
  DOC "Directory containing Valgrind library headers"
)

if(NOT Valgrind_INCLUDE_DIR)
  string(APPEND _reason "valgrind/valgrind.h not found. ")
endif()

block(PROPAGATE Valgrind_VERSION)
  if(Valgrind_INCLUDE_DIR AND EXISTS ${Valgrind_INCLUDE_DIR}/valgrind/config.h)
    set(regex [[^[ \t]*#[ \t]*define[ \t]+VERSION[ \t]+"?([0-9.]+)"?[ \t]*$]])

    file(STRINGS "${Valgrind_INCLUDE_DIR}/valgrind/config.h" results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(Valgrind_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()
endblock()

mark_as_advanced(Valgrind_INCLUDE_DIR)

find_package_handle_standard_args(
  Valgrind
  REQUIRED_VARS
    Valgrind_INCLUDE_DIR
  VERSION_VAR Valgrind_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Valgrind_FOUND)
  return()
endif()

set(Valgrind_INCLUDE_DIRS ${Valgrind_INCLUDE_DIR})

set(HAVE_VALGRIND 1 CACHE INTERNAL "Whether to use Valgrind.")

if(NOT TARGET Valgrind::Valgrind)
  add_library(Valgrind::Valgrind UNKNOWN IMPORTED)

  set_target_properties(
    Valgrind::Valgrind
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${Valgrind_INCLUDE_DIR}"
  )
endif()
