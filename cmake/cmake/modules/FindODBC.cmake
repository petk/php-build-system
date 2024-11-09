#[=============================================================================[
Find the ODBC library.

This module is based on the upstream
[FindODBC](https://cmake.org/cmake/help/latest/module/FindODBC.html) with some
enhancements and adjustments for the PHP build workflow.

Modifications from upstream:

* New result variables:

  * `ODBC_DRIVER`

    Name of the found driver, if any. For example, `unixODBC`, `iODBC`.

  * `ODBC_VERSION`

    Version of the found ODBC library if it was retrieved from config utilities.

* New hints:

  * `ODBC_USE_DRIVER`

    Set to `unixODBC` or `iODBC` to limit searching for specific ODBC driver
    instead of any driver.

* Added pkg-config integration.

* It fixes the limitation where the upstream module can't (yet) select which
  specific ODBC driver to use. Except on Windows, where the driver searching is
  the same as upstream.

* Added package meta-data for FeatureSummary (not relevant for upstream module).
#]=============================================================================]

include(FeatureSummary)

# Define internal variables
set(_odbc_include_paths)
set(_odbc_lib_paths)
set(_odbc_lib_names)
set(_odbc_required_libs_names)
set(_odbc_config_names)
set(_reason)

### Try Windows Kits ##########################################################
if(WIN32)
  # List names of ODBC libraries on Windows
  if(NOT MINGW)
    set(ODBC_LIBRARY odbc32.lib)
  else()
    set(ODBC_LIBRARY libodbc32.a)
  endif()
  set(_odbc_lib_names odbc32;)

  # List additional libraries required to use ODBC library
  if(MSVC OR CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    set(_odbc_required_libs_names odbccp32;ws2_32)
  elseif(MINGW)
    set(_odbc_required_libs_names odbccp32)
  endif()
endif()

### Try unixODBC or iODBC config program ######################################
if(UNIX)
  if(ODBC_USE_DRIVER MATCHES "^(unixODBC|unixodbc|UNIXODBC)$")
    set(_odbc_config_names odbc_config)
  elseif(ODBC_USE_DRIVER MATCHES "^(iODBC|iodbc|IODBC)$")
    set(_odbc_config_names iodbc-config)
  else()
    set(_odbc_config_names odbc_config iodbc-config)
  endif()

  find_program(ODBC_CONFIG
    NAMES ${_odbc_config_names}
    DOC "Path to unixODBC or iODBC config program")
  mark_as_advanced(ODBC_CONFIG)
endif()

if(UNIX AND ODBC_CONFIG)
  # unixODBC and iODBC accept unified command line options
  execute_process(COMMAND ${ODBC_CONFIG} --cflags
    OUTPUT_VARIABLE _cflags OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND ${ODBC_CONFIG} --libs
    OUTPUT_VARIABLE _libs OUTPUT_STRIP_TRAILING_WHITESPACE)

  # Collect paths of include directories from CFLAGS
  separate_arguments(_cflags NATIVE_COMMAND "${_cflags}")
  foreach(arg IN LISTS _cflags)
    if("${arg}" MATCHES "^-I(.*)$")
      list(APPEND _odbc_include_paths "${CMAKE_MATCH_1}")
    endif()
  endforeach()
  unset(_cflags)

  # Collect paths of library names and directories from LIBS
  separate_arguments(_libs NATIVE_COMMAND "${_libs}")
  foreach(arg IN LISTS _libs)
    if("${arg}" MATCHES "^-L(.*)$")
      list(APPEND _odbc_lib_paths "${CMAKE_MATCH_1}")
    elseif("${arg}" MATCHES "^-l(.*)$")
      set(_lib_name ${CMAKE_MATCH_1})
      string(REGEX MATCH "odbc" _is_odbc ${_lib_name})
      if(_is_odbc)
        list(APPEND _odbc_lib_names ${_lib_name})
      else()
        list(APPEND _odbc_required_libs_names ${_lib_name})
      endif()
      unset(_lib_name)
    endif()
  endforeach()
  unset(_libs)
endif()

### Try pkg-config ############################################################
if(NOT ODBC_CONFIG)
  find_package(PkgConfig QUIET)
  if(PKG_CONFIG_FOUND)
    if(ODBC_USE_DRIVER MATCHES "^(unixODBC|unixodbc|UNIXODBC)$")
      pkg_check_modules(PC_ODBC QUIET odbc)
    elseif(ODBC_USE_DRIVER MATCHES "^(iODBC|iodbc|IODBC)$")
      pkg_check_modules(PC_ODBC QUIET libiodbc)
    else()
      pkg_search_module(PC_ODBC QUIET odbc libiodbc)
    endif()
  endif()
endif()

### Try unixODBC or iODBC in include/lib filesystems ##########################
if(UNIX AND NOT ODBC_CONFIG)
  if(ODBC_USE_DRIVER MATCHES "^(unixODBC|unixodbc|UNIXODBC)$")
    set(_odbc_lib_names odbc;unixodbc;)
  elseif(ODBC_USE_DRIVER MATCHES "^(iODBC|iodbc|IODBC)$")
    set(_odbc_lib_names iodbc;)
  else()
    # List names of both ODBC libraries, unixODBC and iODBC
    set(_odbc_lib_names odbc;iodbc;unixodbc;)
  endif()
endif()

### Find include directories ##################################################
find_path(ODBC_INCLUDE_DIR
  NAMES sql.h
  PATHS ${_odbc_include_paths}
  HINTS ${PC_ODBC_INCLUDE_DIRS})

if(NOT ODBC_INCLUDE_DIR AND WIN32)
  set(ODBC_INCLUDE_DIR "")
endif()

### Find libraries ############################################################
if(NOT ODBC_LIBRARY)
  find_library(ODBC_LIBRARY
    NAMES ${_odbc_lib_names}
    PATHS ${_odbc_lib_paths}
    PATH_SUFFIXES odbc
    HINTS ${PC_ODBC_LIBRARY_DIRS})

  foreach(_lib IN LISTS _odbc_required_libs_names)
    find_library(_lib_path
      NAMES ${_lib}
      PATHS ${_odbc_lib_paths} # system parths or collected from ODBC_CONFIG
      PATH_SUFFIXES odbc)
    if(_lib_path)
      list(APPEND _odbc_required_libs_paths ${_lib_path})
    endif()
    unset(_lib_path CACHE)
  endforeach()
endif()

# Unset internal lists as no longer used
unset(_odbc_include_paths)
unset(_odbc_lib_paths)
unset(_odbc_lib_names)
unset(_odbc_required_libs_names)
unset(_odbc_config_names)

### Get version ###############################################################
block(PROPAGATE ODBC_VERSION)
  # ODBC headers don't provide version. Try pkg-confing version, if found.
  if(PC_ODBC_VERSION)
    cmake_path(
      COMPARE
      "${PC_ODBC_INCLUDEDIR}" EQUAL "${ODBC_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(ODBC_VERSION ${PC_ODBC_VERSION})
    endif()
  endif()

  if(NOT ODBC_VERSION AND ODBC_CONFIG)
    execute_process(
      COMMAND ${ODBC_CONFIG} --version
        OUTPUT_VARIABLE _odbc_version
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )
    if(_odbc_version MATCHES "[0-9]+\.[0-9.]*")
      set(ODBC_VERSION ${_odbc_version})
    endif()
  endif()
endblock()

### Set result variables ######################################################
set(_odbc_required_vars ODBC_LIBRARY)
if(NOT WIN32)
  list(APPEND _odbc_required_vars ODBC_INCLUDE_DIR)
endif()

if(NOT ODBC_INCLUDE_DIR)
  string(APPEND _reason "ODBC sql.h not found. ")
endif()

if(NOT ODBC_LIBRARY)
  string(APPEND _reason "ODBC library not found. ")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  ODBC
  REQUIRED_VARS ${_odbc_required_vars}
  VERSION_VAR ODBC_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_odbc_required_vars)
unset(_reason)

mark_as_advanced(ODBC_LIBRARY ODBC_INCLUDE_DIR)

set(ODBC_INCLUDE_DIRS ${ODBC_INCLUDE_DIR})
list(APPEND ODBC_LIBRARIES ${ODBC_LIBRARY})
list(APPEND ODBC_LIBRARIES ${_odbc_required_libs_paths})

### Import targets ############################################################
if(ODBC_FOUND)
  if(NOT TARGET ODBC::ODBC)
    if(IS_ABSOLUTE "${ODBC_LIBRARY}")
      add_library(ODBC::ODBC UNKNOWN IMPORTED)
      set_target_properties(ODBC::ODBC PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        IMPORTED_LOCATION "${ODBC_LIBRARY}")
    else()
      add_library(ODBC::ODBC INTERFACE IMPORTED)
      set_target_properties(ODBC::ODBC PROPERTIES
        IMPORTED_LIBNAME "${ODBC_LIBRARY}")
    endif()
    set_target_properties(ODBC::ODBC PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${ODBC_INCLUDE_DIR}")

    if(_odbc_required_libs_paths)
      set_property(TARGET ODBC::ODBC APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES "${_odbc_required_libs_paths}")
    endif()
  endif()

  if(NOT ODBC_DRIVER)
    if(ODBC_CONFIG)
      execute_process(
        COMMAND ${ODBC_CONFIG}
          OUTPUT_VARIABLE _output
          ERROR_VARIABLE _output
          OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_QUIET
      )
      if(_output MATCHES "^iODBC")
        set(ODBC_DRIVER "iODBC")
      elseif(_output MATCHES "^Usage: odbc_config")
        set(ODBC_DRIVER "unixODBC")
      endif()
      unset(_output)
    elseif(PC_ODBC_FOUND)
      if(PC_ODBC_MODULE_NAME STREQUAL "libiodbc")
        set(ODBC_DRIVER "iODBC")
      elseif(PC_ODBC_MODULE_NAME STREQUAL "odbc")
        set(ODBC_DRIVER "unixODBC")
      endif()
    elseif(WIN32)
      set(ODBC_DRIVER "Windows")
    endif()

    if(NOT ODBC_DRIVER)
      if(ODBC_LIBRARY MATCHES "libiodbc")
        set(ODBC_DRIVER "iODBC")
      elseif(ODBC_LIBRARY MATCHES "odbc")
        set(ODBC_DRIVER "unixODBC")
      endif()
    endif()
  endif()
endif()

unset(_odbc_required_libs_paths)

### Set package metadata ######################################################
if(ODBC_DRIVER STREQUAL "unixODBC" OR ODBC_USE_DRIVER STREQUAL "unixODBC")
  set(_odbc_url "https://www.unixodbc.org/")
  set(_odbc_description "Open Database Connectivity library for *nix systems")
elseif(ODBC_DRIVER STREQUAL "iODBC" OR ODBC_USE_DRIVER STREQUAL "iODBC")
  set(_odbc_url "https://www.iodbc.org")
  set(_odbc_description "Independent Open Database Connectivity library")
else()
  set(_odbc_url "https://en.wikipedia.org/wiki/Open_Database_Connectivity")
  set(_odbc_description "Open Database Connectivity library")
endif()
set_package_properties(
  ODBC
  PROPERTIES
    URL "${_odbc_url}"
    DESCRIPTION "${_odbc_description}"
)
unset(_odbc_url)
unset(_odbc_description)
