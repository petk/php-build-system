#[=============================================================================[
# FindNetSnmp

Finds the Net-SNMP library:

```cmake
find_package(NetSnmp [<version>] [...])
```

## Imported targets

This module defines the following imported targets:

* `NetSnmp::NetSnmp` - The package library, if found.

## Result variables

* `NetSnmp_FOUND` - Boolean indicating whether the package is found.
* `NetSnmp_VERSION` - The version of package found.

## Cache variables

* `NetSnmp_INCLUDE_DIR` - Directory containing package library headers.
* `NetSnmp_LIBRARY` - The path to the package library.
* `NetSnmp_EXECUTABLE` - Path to net-snmp-config utility.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(NetSnmp)
target_link_libraries(example PRIVATE NetSnmp::NetSnmp)
```
#]=============================================================================]

include(CheckSymbolExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  NetSnmp
  PROPERTIES
    URL "http://www.net-snmp.org/"
    DESCRIPTION "Simple network management protocol library"
)

set(_reason "")

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_NetSnmp QUIET netsnmp)
endif()

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

  # TODO: To be added when linking static NetSnmp library.
  execute_process(
    COMMAND "${NetSnmp_EXECUTABLE}" --external-libs
    OUTPUT_VARIABLE _netsnmp_config_external_libraries
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  separate_arguments(
    _netsnmp_config_external_libraries
    NATIVE_COMMAND
    "${_netsnmp_config_external_libraries}"
  )
  list(FILTER _netsnmp_config_external_libraries INCLUDE REGEX "^(-L|-l)")

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
  HINTS
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
  HINTS
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
    set(regex "^[ \t]*#[ \t]*define[ \t]+PACKAGE_VERSION[ \t]+\"([^\"]+)\"[^\n]*$")

    file(
      STRINGS
      ${NetSnmp_INCLUDE_DIR}/net-snmp/net-snmp-config.h
      result
      REGEX
      "${regex}"
    )

    if(result MATCHES "${regex}")
      set(NetSnmp_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT NetSnmp_VERSION
    AND PC_NetSNMP_VERSION
    AND NetSnmp_INCLUDE_DIR IN_LIST PC_NetSnmp_INCLUDE_DIRS
  )
    set(NetSnmp_VERSION ${PC_NetSnmp_VERSION})
  endif()

  # Try net-snmp-config.
  if(NOT NetSnmp_VERSION AND _netsnmp_config_version AND _netsnmp_config_libdir)
    cmake_path(GET NetSnmp_LIBRARY PARENT_PATH parent)
    if(_netsnmp_config_libdir PATH_EQUAL parent)
      set(NetSnmp_VERSION ${_netsnmp_config_version})
    endif()
  endif()
endblock()

# Sanity check.
if(NetSnmp_INCLUDE_DIR AND NetSnmp_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${NetSnmp_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${NetSnmp_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_symbol_exists(
      init_snmp
      "net-snmp/net-snmp-config.h;net-snmp/net-snmp-includes.h"
      _NetSnmp_SANITY_CHECK
    )
  cmake_pop_check_state()

  if(NOT _NetSnmp_SANITY_CHECK)
    string(APPEND _reason "Sanity check failed: init_snmp not found. ")
  endif()
endif()

mark_as_advanced(NetSnmp_INCLUDE_DIR NetSnmp_LIBRARY NetSnmp_EXECUTABLE)

find_package_handle_standard_args(
  NetSnmp
  REQUIRED_VARS
    NetSnmp_LIBRARY
    NetSnmp_INCLUDE_DIR
    _NetSnmp_SANITY_CHECK
  VERSION_VAR NetSnmp_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT NetSnmp_FOUND)
  return()
endif()

if(NOT TARGET NetSnmp::NetSnmp)
  add_library(NetSnmp::NetSnmp UNKNOWN IMPORTED)

  set_target_properties(
    NetSnmp::NetSnmp
    PROPERTIES
      IMPORTED_LOCATION "${NetSnmp_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${NetSnmp_INCLUDE_DIR}"
  )
endif()
