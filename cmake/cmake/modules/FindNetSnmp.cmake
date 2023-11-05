#[=============================================================================[
Find the Net-SNMP library.

Module defines the following IMPORTED targets:

  NetSnmp::NetSnmp
    The Net-SNMP library, if found.

Result variables:

  NetSnmp_FOUND
    Set if Net-SNMP library is found.
  NetSnmp_INCLUDE_DIRS
    A list of include directories for using Net-SNMP library.
  NetSnmp_LIBRARIES
    A list of libraries for using Net-SNMP library.
  NetSnmp_VERSION
    Version string of found Net-SNMP library.
  NetSnmp_EXECUTABLE
    Path to net-snmp-config utility.

Hints:

  The NetSnmp_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(NetSnmp PROPERTIES
  URL "http://www.net-snmp.org/"
  DESCRIPTION "Simple network management protocol library"
)

find_program(NetSnmp_EXECUTABLE net-snmp-config)

if(NetSnmp_EXECUTABLE)
  execute_process(
    COMMAND ${NetSnmp_EXECUTABLE} --prefix
    OUTPUT_VARIABLE NetSnmp_INCLUDE_DIRS
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  string(APPEND NetSnmp_INCLUDE_DIRS "/include")

  execute_process(
    COMMAND ${NetSnmp_EXECUTABLE} --netsnmp-libs
    OUTPUT_VARIABLE NetSnmp_LIBRARY
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  execute_process(
    COMMAND ${NetSnmp_EXECUTABLE} --external-libs
    OUTPUT_VARIABLE _external_libraries
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  set(NetSnmp_LIBRARIES "${NetSnmp_LIBRARY} ${_external_libraries}")

  execute_process(
    COMMAND ${NetSnmp_EXECUTABLE} --version
    OUTPUT_VARIABLE NetSnmp_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
else()
  find_path(
    NetSnmp_INCLUDE_DIRS "net-snmp/net-snmp-config.h"
    DOC "Net-SNMP include directories"
  )

  find_library(NetSnmp_LIBRARY NAMES netsnmp DOC "The Net-SNMP library")
  set(NetSnmp_LIBRARIES ${NetSnmp_LIBRARY})

  if(NetSnmp_INCLUDE_DIRS)
    set(_regex "#[ \t]*define[ \t]+PACKAGE_VERSION[ \t]+\"([0-9.]+)\"[ \t]*$")

    file(
      STRINGS
      "${NetSnmp_INCLUDE_DIRS}/net-snmp/net-snmp-config.h"
      _netsnmp_version_string
      REGEX "${_regex}"
    )

    foreach(version ${_netsnmp_version_string})
      if(version MATCHES "${_regex}")
        set(NetSnmp_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()

    unset(_regex)
  endif()
endif()

set(_reason_failure_message "")

if(NOT NetSnmp_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    Net-SNMP include directory not found."
  )
endif()

if(NOT NetSnmp_LIBRARY)
  string(
    APPEND _reason_failure_message
    "\n    Net-SNMP library not found."
  )
endif()

if(NOT NetSnmp_VERSION)
  string(
    APPEND _reason_failure_message
    "\n    Net-SNMP version not found."
  )
endif()

# Sanity check.
if(NetSnmp_LIBRARY)
  check_library_exists("${NetSnmp_LIBRARY}" init_snmp "" HAVE_INIT_SNMP)
endif()

if(NOT HAVE_INIT_SNMP)
  string(
    APPEND _reason_failure_message
    "\n    SNMP sanity check failed. "
    "The init_snmp was not found in the Net-SNMP library."
  )
endif()

mark_as_advanced(NetSnmp_INCLUDE_DIRS NetSnmp_LIBRARIES)

find_package_handle_standard_args(
  NetSnmp
  REQUIRED_VARS NetSnmp_LIBRARY NetSnmp_INCLUDE_DIRS HAVE_INIT_SNMP
  VERSION_VAR NetSnmp_VERSION
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(NetSnmp_FOUND AND NOT TARGET NetSnmp::NetSnmp)
  add_library(NetSnmp::NetSnmp INTERFACE IMPORTED)

  set_target_properties(NetSnmp::NetSnmp PROPERTIES
    INTERFACE_LINK_LIBRARIES "${NetSnmp_LIBRARIES}"
    INTERFACE_INCLUDE_DIRECTORIES "${NetSnmp_INCLUDE_DIRS}"
  )
endif()
