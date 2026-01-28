#[=============================================================================[
# FindNetSnmp

Finds the Net-SNMP library:

```cmake
find_package(NetSnmp [<version>] [...])
```

## Imported targets

This module provides the following imported targets:

* `NetSnmp::NetSnmp` - The package library, if found.

## Result variables

This module defines the following variables:

* `NetSnmp_FOUND` - Boolean indicating whether (the requested version of)
  package was found.
* `NetSnmp_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `NetSnmp_INCLUDE_DIR` - Directory containing package library headers.
* `NetSnmp_LIBRARY` - The path to the package library.
* `NetSnmp_CONFIG_EXECUTABLE` - Path to net-snmp-config utility.

## Hints

This module accepts the following variables before calling
`find_package(NetSnmp)`:

* `NetSnmp_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

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
  if(NetSnmp_ROOT OR NETSNMP_ROOT)
    set(saved "${CMAKE_PREFIX_PATH}")
    list(PREPEND CMAKE_PREFIX_PATH ${NetSnmp_ROOT} ${NETSNMP_ROOT})
  endif()

  pkg_check_modules(PC_NetSnmp QUIET netsnmp)

  unset(CMAKE_PREFIX_PATH)
  if(saved)
    set(CMAKE_PREFIX_PATH ${saved})
  endif()
  unset(saved)
endif()

find_program(
  NetSnmp_CONFIG_EXECUTABLE
  NAMES net-snmp-config
  DOC "Path to net-snmp-config utility"
)
mark_as_advanced(NetSnmp_CONFIG_EXECUTABLE)

if(NetSnmp_CONFIG_EXECUTABLE AND NOT PC_NetSnmp_FOUND)
  execute_process(
    COMMAND "${NetSnmp_CONFIG_EXECUTABLE}" --prefix
    OUTPUT_VARIABLE _netsnmp_config_include_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if(_netsnmp_config_include_dir)
    string(APPEND _netsnmp_config_include_dir "/include")
  endif()

  execute_process(
    COMMAND "${NetSnmp_CONFIG_EXECUTABLE}" --libdir
    OUTPUT_VARIABLE _netsnmp_config_libdir
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if(_netsnmp_config_libdir)
    string(REGEX REPLACE "^-L" "" _netsnmp_config_libdir ${_netsnmp_config_libdir})
  endif()
endif()

find_path(
  NetSnmp_INCLUDE_DIR
  NAMES net-snmp/net-snmp-config.h
  HINTS
    ${PC_NetSnmp_INCLUDE_DIRS}
    ${_netsnmp_config_include_dir}
  DOC "Directory containing Net-SNMP library headers"
)
mark_as_advanced(NetSnmp_INCLUDE_DIR)

if(NOT NetSnmp_INCLUDE_DIR)
  string(APPEND _reason "net-snmp/net-snmp-config.h not found. ")
endif()

# Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES.
if(NetSnmp_USE_STATIC_LIBS)
  set(_netsnmp_cmake_find_library_suffixes ${CMAKE_FIND_LIBRARY_SUFFIXES})
  if(WIN32)
    list(PREPEND CMAKE_FIND_LIBRARY_SUFFIXES .lib .a)
  else()
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
  endif()
endif()

find_library(
  NetSnmp_LIBRARY
  NAMES netsnmp
  HINTS
    ${PC_NetSnmp_LIBRARY_DIRS}
    ${_netsnmp_config_libdir}
  DOC "The path to the Net-SNMP library"
)
mark_as_advanced(NetSnmp_LIBRARY)

if(NOT NetSnmp_LIBRARY)
  string(APPEND _reason "Net-SNMP library not found. ")
endif()

# Restore the original find library ordering.
if(NetSnmp_USE_STATIC_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${_netsnmp_cmake_find_library_suffixes})
endif()

# Ensure NetSnmp_CONFIG_EXECUTABLE belongs to the found Net-SNMP package.
block()
  if(NetSnmp_CONFIG_EXECUTABLE AND NetSnmp_LIBRARY AND _netsnmp_config_libdir)
    cmake_path(GET NetSnmp_LIBRARY PARENT_PATH parent)
    if(NOT _netsnmp_config_libdir PATH_EQUAL parent)
      set_property(
        CACHE NetSnmp_CONFIG_EXECUTABLE
        PROPERTY VALUE "NetSnmp_CONFIG_EXECUTABLE-NOTFOUND"
      )
    endif()
  endif()
endblock()

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
  if(NOT NetSnmp_VERSION AND NetSnmp_CONFIG_EXECUTABLE)
    execute_process(
      COMMAND "${NetSnmp_CONFIG_EXECUTABLE}" --version
      OUTPUT_VARIABLE NetSnmp_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()
endblock()

# Sanity check.
if(NetSnmp_INCLUDE_DIR AND NetSnmp_LIBRARY)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_INCLUDES ${NetSnmp_INCLUDE_DIR})
    set(CMAKE_REQUIRED_LIBRARIES ${NetSnmp_LIBRARY})
    set(CMAKE_REQUIRED_QUIET TRUE)

    block()
      if(NetSnmp_USE_STATIC_LIBS)
        set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
      endif()
      check_symbol_exists(
        init_snmp
        "net-snmp/net-snmp-config.h;net-snmp/net-snmp-includes.h"
        NetSnmp_SANITY_CHECK
      )
    endblock()
  cmake_pop_check_state()

  if(NOT NetSnmp_SANITY_CHECK)
    string(APPEND _reason "Sanity check failed: init_snmp not found. ")
  endif()
endif()

find_package_handle_standard_args(
  NetSnmp
  REQUIRED_VARS
    NetSnmp_LIBRARY
    NetSnmp_INCLUDE_DIR
    NetSnmp_SANITY_CHECK
  VERSION_VAR NetSnmp_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_netsnmp_cmake_find_library_suffixes)
unset(_netsnmp_config_include_dir)
unset(_netsnmp_config_libdir)
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

  if(NetSnmp_USE_STATIC_LIBS)
    set(_netsnmp_external_libraries "")

    if(PC_NetSnmp_FOUND AND PC_NetSnmp_STATIC_LIBRARIES)
      set(_netsnmp_external_libraries "${PC_NetSnmp_STATIC_LIBRARIES}")
      list(REMOVE_ITEM _netsnmp_external_libraries netsnmp)
    elseif(NetSnmp_CONFIG_EXECUTABLE)
      execute_process(
        COMMAND "${NetSnmp_CONFIG_EXECUTABLE}" --external-libs
        OUTPUT_VARIABLE _netsnmp_external_libraries
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
      )
      separate_arguments(
        _netsnmp_external_libraries
        NATIVE_COMMAND
        "${_netsnmp_external_libraries}"
      )
      list(FILTER _netsnmp_external_libraries INCLUDE REGEX "^-l")
      list(TRANSFORM _netsnmp_external_libraries REPLACE "^-l" "")
    endif()

    if(_netsnmp_external_libraries)
      set_target_properties(
        NetSnmp::NetSnmp
        PROPERTIES
          INTERFACE_LINK_LIBRARIES "${_netsnmp_external_libraries}")
    endif()

    unset(_netsnmp_external_libraries)
  endif()
endif()
