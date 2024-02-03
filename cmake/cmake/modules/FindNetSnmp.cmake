#[=============================================================================[
Find the Net-SNMP library.

Module defines the following IMPORTED target(s):

  NetSnmp::NetSnmp
    The package library, if found.

Result variables:

  NetSnmp_FOUND
    Whether the package has been found.
  NetSnmp_INCLUDE_DIRS
    Include directories needed to use this package.
  NetSnmp_LIBRARIES
    Libraries needed to link to the package library.
  NetSnmp_VERSION
    Package version, if found.

Cache variables:

  NetSnmp_INCLUDE_DIR
    Directory containing package library headers.
  NetSnmp_LIBRARY
    The path to the package library.
  NetSnmp_EXECUTABLE
    Path to net-snmp-config utility.

Hints:

  The NetSnmp_ROOT variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  NetSnmp
  PROPERTIES
    URL "http://www.net-snmp.org/"
    DESCRIPTION "Simple network management protocol library"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_NetSnmp QUIET netsnmp)

find_program(
  NetSnmp_EXECUTABLE
  NAMES net-snmp-config
  DOC "Path to net-snmp-config utility"
)

if(NetSnmp_EXECUTABLE)
  execute_process(
    COMMAND "${NetSnmp_EXECUTABLE}" --prefix
    OUTPUT_VARIABLE _netsnmp_config_include_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if(_netsnmp_config_include_dir)
    string(APPEND _netsnmp_config_include_dir "/include")
  endif()

  # TODO: To be added.
  execute_process(
    COMMAND "${NetSnmp_EXECUTABLE}" --external-libs
    OUTPUT_VARIABLE _netsnmp_config_external_libraries
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  execute_process(
    COMMAND "${NetSnmp_EXECUTABLE}" --libdir
    OUTPUT_VARIABLE _netsnmp_config_libdir
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if(_netsnmp_config_libdir)
    string(REGEX REPLACE "^-L" "" _netsnmp_config_libdir ${_netsnmp_config_libdir})
  endif()

  execute_process(
    COMMAND "${NetSnmp_EXECUTABLE}" --version
    OUTPUT_VARIABLE _netsnmp_config_version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

find_path(
  NetSnmp_INCLUDE_DIR
  NAMES net-snmp/net-snmp-config.h
  PATHS
    ${PC_NetSnmp_INCLUDE_DIRS}
    ${_netsnmp_config_include_dir}
  DOC "Directory containing Net-SNMP library headers"
)

if(NOT NetSnmp_INCLUDE_DIR)
  string(APPEND _reason "net-snmp/net-snmp-config.h not found. ")
endif()

find_library(
  NetSnmp_LIBRARY
  NAMES netsnmp
  PATHS
    ${PC_NetSnmp_LIBRARY_DIRS}
    ${_netsnmp_config_libdir}
  DOC "The path to the Net-SNMP library"
)

if(NOT NetSnmp_LIBRARY)
  string(APPEND _reason "Net-SNMP library not found. ")
endif()

# Get version.
block(PROPAGATE NetSnmp_VERSION)
  if(NetSnmp_INCLUDE_DIR)
    set(regex "^[ \t]*#[ \t]*define[ \t]+PACKAGE_VERSION[ \t]+\"([0-9.]+)\"[^\r\n]*$")

    file(
      STRINGS
      ${NetSnmp_INCLUDE_DIR}/net-snmp/net-snmp-config.h
      results
      REGEX
      "${regex}"
    )

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(NetSnmp_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()

  # Try finding version with pkgconf.
  if(NOT NetSnmp_VERSION AND PC_NetSNMP_VERSION)
    cmake_path(
      COMPARE
      "${PC_NetSnmp_INCLUDEDIR}" EQUAL "${NetSnmp_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(NetSnmp_VERSION ${PC_NetSnmp_VERSION})
    endif()
  endif()

  # Try finding version with net-snmp-config.
  if(NOT NetSnmp_VERSION AND _netsnmp_config_version AND _netsnmp_config_libdir)
    cmake_path(GET NetSnmp_LIBRARY PARENT_PATH parent)
    cmake_path(COMPARE "${_netsnmp_config_libdir}" EQUAL "${parent}" isEqual)

    if(isEqual)
      set(NetSnmp_VERSION ${_netsnmp_config_version})
    endif()
  endif()
endblock()

# Sanity check.
if(NetSnmp_LIBRARY)
  check_library_exists("${NetSnmp_LIBRARY}" init_snmp "" _netsnmp_sanity_check)

  if(NOT _netsnmp_sanity_check)
    string(APPEND _reason "Sanity check failed: init_snmp not found. ")
  endif()
endif()

mark_as_advanced(NetSnmp_INCLUDE_DIR NetSnmp_LIBRARY NetSnmp_EXECUTABLE)

find_package_handle_standard_args(
  NetSnmp
  REQUIRED_VARS
    NetSnmp_LIBRARY
    NetSnmp_INCLUDE_DIR
    _netsnmp_sanity_check
  VERSION_VAR NetSnmp_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT NetSnmp_FOUND)
  return()
endif()

set(NetSnmp_INCLUDE_DIRS ${NetSnmp_INCLUDE_DIR})
set(NetSnmp_LIBRARIES ${NetSnmp_LIBRARY})

if(NOT TARGET NetSnmp::NetSnmp)
  add_library(NetSnmp::NetSnmp UNKNOWN IMPORTED)

  set_target_properties(
    NetSnmp::NetSnmp
    PROPERTIES
      IMPORTED_LOCATION "${NetSnmp_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${NetSnmp_INCLUDE_DIR}"
  )
endif()
