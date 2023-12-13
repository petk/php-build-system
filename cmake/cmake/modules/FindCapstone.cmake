#[=============================================================================[
Find the Capstone library.

Module defines the following IMPORTED targets:

  Capstone::Capstone
    The Capstone library, if found.

Result variables:

  Capstone_FOUND
    Whether Capstone library is found.
  Capstone_INCLUDE_DIRS
    A list of include directories for using Capstone library.
  Capstone_LIBRARIES
    A list of libraries for using Capstone library.
  Capstone_VERSION
    Version string of found Capstone library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Capstone PROPERTIES
  URL "https://www.capstone-engine.org"
  DESCRIPTION "Disassembly engine"
)

set(_reason_failure_message)

find_path(Capstone_INCLUDE_DIR capstone/capstone.h)

if(NOT Capstone_INCLUDE_DIR)
  string(
    APPEND _reason_failure_message
    "\n    capstone/capstone.h not found."
  )
else()
  # Capstone might be included with <capstone.h> instead of the recommended
  # <capstone/capstone.h>. Here both include directories are added so the code
  # can work with both includes. This can be simplified in the future.
  # See: https://github.com/capstone-engine/capstone/issues/1982
  set(Capstone_INCLUDE_DIRS ${Capstone_INCLUDE_DIR} ${Capstone_INCLUDE_DIR}/capstone)
endif()

find_library(Capstone_LIBRARIES NAMES capstone DOC "The Capstone library")

if(NOT Capstone_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Capstone not found. Please install the Capstone library."
  )
endif()

block(PROPAGATE Capstone_VERSION)
  if(Capstone_INCLUDE_DIR)
    file(
      STRINGS
      "${Capstone_INCLUDE_DIR}/capstone/capstone.h"
      strings
      REGEX
      "^#[ \t]*define[ \t]+(CS_API_MAJOR|CS_API_MINOR|CS_VERSION_EXTRA)[ \t]+[0-9]+[ \t]*$"
    )

    foreach(item CS_API_MAJOR CS_API_MINOR CS_VERSION_EXTRA)
      foreach(line ${strings})
        if(line MATCHES "^#[ \t]*define[ \t]+${item}[ \t]+([0-9]+)[ \t]*$")
          if(Capstone_VERSION)
            string(APPEND Capstone_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Capstone_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
endblock()

find_package_handle_standard_args(
  Capstone
  REQUIRED_VARS Capstone_LIBRARIES Capstone_INCLUDE_DIRS
  VERSION_VAR Capstone_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Capstone_FOUND AND NOT TARGET Capstone::Capstone)
  add_library(Capstone::Capstone INTERFACE IMPORTED)

  set_target_properties(Capstone::Capstone PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Capstone_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Capstone_LIBRARIES}"
  )
endif()
