#[=============================================================================[
# FindDmalloc

Find the Dmalloc library.

Module defines the following `IMPORTED` target(s):

* `Dmalloc::Dmalloc` - The package library, if found.

## Result variables

* `Dmalloc_FOUND` - Whether the package has been found.
* `Dmalloc_INCLUDE_DIRS` - Include directories needed to use this package.
* `Dmalloc_LIBRARIES` - Libraries needed to link to the package library.
* `Dmalloc_VERSION` - Package version, if found.

## Cache variables

* `Dmalloc_INCLUDE_DIR` - Directory containing package library headers.
* `Dmalloc_LIBRARY` - The path to the package library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Dmalloc
  PROPERTIES
    URL "https://dmalloc.com/"
    DESCRIPTION "Debug Malloc Library"
)

set(_reason "")

find_path(
  Dmalloc_INCLUDE_DIR
  NAMES dmalloc.h
  DOC "Directory containing Dmalloc library headers"
)

if(NOT Dmalloc_INCLUDE_DIR)
  string(APPEND _reason "dmalloc.h not found. ")
endif()

find_library(
  Dmalloc_LIBRARY
  NAMES dmalloc
  DOC "The path to the Dmalloc library"
)

if(NOT Dmalloc_LIBRARY)
  string(APPEND _reason "Dmalloc library not found. ")
endif()

block(PROPAGATE Dmalloc_VERSION)
  if(Dmalloc_INCLUDE_DIR)
    file(
      STRINGS
      ${Dmalloc_INCLUDE_DIR}/dmalloc.h
      results
      REGEX
      "^#[ \t]*define[ \t]+DMALLOC_VERSION_(MAJOR|MINOR|PATCH)[ \t]+[0-9]+[ \t]*[^\n]*$"
    )

    unset(Dmalloc_VERSION)

    foreach(item MAJOR MINOR PATCH)
      foreach(line ${results})
        if(line MATCHES "^#[ \t]*define[ \t]+DMALLOC_VERSION_${item}[ \t]+([0-9]+)[ \t]*[^\n]*$")
          if(DEFINED Dmalloc_VERSION)
            string(APPEND Dmalloc_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Dmalloc_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

mark_as_advanced(Dmalloc_INCLUDE_DIR Dmalloc_LIBRARY)

find_package_handle_standard_args(
  Dmalloc
  REQUIRED_VARS
    Dmalloc_LIBRARY
    Dmalloc_INCLUDE_DIR
  VERSION_VAR Dmalloc_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Dmalloc_FOUND)
  return()
endif()

set(Dmalloc_INCLUDE_DIRS ${Dmalloc_INCLUDE_DIR})
set(Dmalloc_LIBRARIES ${Dmalloc_LIBRARY})

if(NOT TARGET Dmalloc::Dmalloc)
  add_library(Dmalloc::Dmalloc UNKNOWN IMPORTED)

  set_target_properties(
    Dmalloc::Dmalloc
    PROPERTIES
      IMPORTED_LOCATION "${Dmalloc_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Dmalloc_INCLUDE_DIR}"
      # Enable the Dmalloc check-funcs token:
      INTERFACE_COMPILE_DEFINITIONS DMALLOC_FUNC_CHECK
  )
endif()
