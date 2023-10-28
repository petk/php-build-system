#[=============================================================================[
Find the Tokyo Cabinet library.

Module defines the following IMPORTED targets:

  TokyoCabinet::TokyoCabinet
    The Tokyo Cabinet library, if found.

Result variables:

  TokyoCabinet_FOUND
    Set to 1 if Tokyo Cabinet has been found.
  TokyoCabinet_INCLUDE_DIRS
    A list of include directories for using Tokyo Cabinet library.
  TokyoCabinet_LIBRARIES
    A list of libraries for linking when using Tokyo Cabinet library.

Hints:

  The TokyoCabinet_ROOT variable adds search path for finding the Tokyo Cabinet
  on custom location.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(TokyoCabinet PROPERTIES
  URL "https://en.wikipedia.org/wiki/Tkrzw"
  DESCRIPTION "Key-value database library"
)

find_path(TokyoCabinet_INCLUDE_DIRS tcadb.h)

find_library(TokyoCabinet_LIBRARIES NAMES tokyocabinet DOC "The Tokyo Cabinet library")

mark_as_advanced(TokyoCabinet_LIBRARIES TokyoCabinet_INCLUDE_DIRS)

# Sanity check.
check_library_exists("${TokyoCabinet_LIBRARIES}" tcadbopen "" HAVE_TCADBOPEN)

find_package_handle_standard_args(
  TokyoCabinet
  REQUIRED_VARS TokyoCabinet_LIBRARIES TokyoCabinet_INCLUDE_DIRS HAVE_TCADBOPEN
)

if(NOT TokyoCabinet_FOUND)
  return()
endif()

if(NOT TARGET TokyoCabinet::TokyoCabinet)
  add_library(TokyoCabinet::TokyoCabinet INTERFACE IMPORTED)

  set_target_properties(TokyoCabinet::TokyoCabinet PROPERTIES
    INTERFACE_LINK_LIBRARIES "${TokyoCabinet_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${TokyoCabinet_INCLUDE_DIRS}"
  )
endif()
