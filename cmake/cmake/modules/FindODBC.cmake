#[=============================================================================[
# FindODBC

Find the ODBC library.

This module is based on the upstream
[FindODBC](https://cmake.org/cmake/help/latest/module/FindODBC.html) with some
enhancements and adjustments for the PHP build workflow.

## Modifications from upstream

* Additional result variables:

  * `ODBC_DRIVER`

    Name of the found driver, if any. For example, `unixODBC`, `iODBC`. On
    Windows in MinGW environment it is set to `unixODBC`, and to `Windows` for
    the rest of the Windows system.

  * `ODBC_VERSION`

    Version of the found ODBC library if it was retrieved from config utilities.

* Additional cache variables:

  * `ODBC_COMPILE_DEFINITIONS`

    A `;`-list of compile definitions.

  * `ODBC_COMPILE_OPTIONS`

    A `;`-list of compile options.

  * `ODBC_LINK_OPTIONS`

    A `;`-list of linker options.

  * `ODBC_LIBRARY_DIR`

    The path to the ODBC library directory that contains the ODBC library.

* Additional hints:

  * `ODBC_USE_DRIVER`

    Set to `unixODBC` or `iODBC` to limit searching for specific ODBC driver
    instead of any driver. On Windows, the searched driver will be the core ODBC
    Windows implementation only. On Windows in MinGW environment, there is at
    the time of writing `unixODBC` implementation available in the default
    MinGW installation and as a standalone package. The driver name is
    case-insensitive and if supported it will be adjusted to the expected case.

* Added pkg-config integration.

* Fixed limitation where the upstream module can't (yet) select which specific
  ODBC driver to use.

* Added package meta-data for FeatureSummary.

* Fixed finding ODBC on Windows and MinGW.
#]=============================================================================]

include(FeatureSummary)

# Define internal variables
set(_odbc_include_paths)
set(_odbc_lib_paths)
set(_odbc_lib_names)
set(_odbc_required_libs_names)
set(_odbc_config_names)
set(_reason)

### To manually override build options of the ODBC library ####################
set(ODBC_COMPILE_DEFINITIONS "" CACHE STRING "ODBC library compile definitions")
set(ODBC_COMPILE_OPTIONS "" CACHE STRING "ODBC library compile options")
set(ODBC_LINK_OPTIONS "" CACHE STRING "ODBC library linker flags")
mark_as_advanced(
  ODBC_COMPILE_DEFINITIONS
  ODBC_COMPILE_OPTIONS
  ODBC_LINK_OPTIONS
)

# Adjust ODBC driver string case sensitivity.
if(ODBC_USE_DRIVER)
  string(TOLOWER "${ODBC_USE_DRIVER}" _odbc_use_driver)
  if(_odbc_use_driver STREQUAL "unixodbc")
    set(ODBC_USE_DRIVER "unixODBC")
  elseif(_odbc_use_driver STREQUAL "iodbc")
    set(ODBC_USE_DRIVER "iODBC")
  endif()
  unset(_odbc_use_driver)
endif()

### Try unixODBC or iODBC config program ######################################
if(ODBC_USE_DRIVER STREQUAL "unixODBC")
  set(_odbc_config_names odbc_config)
elseif(ODBC_USE_DRIVER STREQUAL "iODBC")
  set(_odbc_config_names iodbc-config)
else()
  set(_odbc_config_names odbc_config iodbc-config)
endif()

find_program(ODBC_CONFIG
  NAMES ${_odbc_config_names}
  DOC "Path to unixODBC or iODBC config program")
mark_as_advanced(ODBC_CONFIG)

### Try pkg-config. ###########################################################
if(NOT ODBC_CONFIG)
  find_package(PkgConfig QUIET)
  if(PKG_CONFIG_FOUND)
    if(ODBC_USE_DRIVER STREQUAL "unixODBC")
      pkg_check_modules(PC_ODBC QUIET odbc)
    elseif(ODBC_USE_DRIVER STREQUAL "iODBC")
      pkg_check_modules(PC_ODBC QUIET libiodbc)
    else()
      pkg_search_module(PC_ODBC QUIET odbc libiodbc)
    endif()
  endif()
endif()

### Try Windows ###############################################################
if(NOT ODBC_CONFIG AND NOT PC_ODBC_FOUND AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # List names of ODBC libraries on Windows
  if(NOT MINGW)
    set(_odbc_lib_names odbc32.lib)
  else()
    set(_odbc_lib_names libodbc32.a)
  endif()
  list(APPEND _odbc_lib_names odbc32)

  # List additional libraries required to use ODBC library
  if(MSVC OR CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    set(_odbc_required_libs_names odbccp32;ws2_32)
  elseif(MINGW)
    set(_odbc_required_libs_names odbccp32)
  endif()
endif()

if(ODBC_CONFIG)
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

### Try unixODBC or iODBC in include/lib filesystems ##########################
if(UNIX AND NOT ODBC_CONFIG)
  if(ODBC_USE_DRIVER STREQUAL "unixODBC")
    set(_odbc_lib_names odbc;unixodbc;)
  elseif(ODBC_USE_DRIVER STREQUAL "iODBC")
    set(_odbc_lib_names iodbc;)
  else()
    # List names of both ODBC libraries, unixODBC and iODBC
    set(_odbc_lib_names odbc;iodbc;unixodbc;)
  endif()
endif()

### Find include directories ##################################################
find_path(
  ODBC_INCLUDE_DIR
  NAMES sql.h
  HINTS
    ${_odbc_include_paths}
    ${PC_ODBC_INCLUDE_DIRS}
)

if(NOT ODBC_INCLUDE_DIR AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(ODBC_INCLUDE_DIR "")
endif()

### Find libraries ############################################################
if(NOT ODBC_LIBRARY)
  find_library(ODBC_LIBRARY
    NAMES ${_odbc_lib_names}
    HINTS ${_odbc_lib_paths}
    PATH_SUFFIXES odbc
    HINTS ${PC_ODBC_LIBRARY_DIRS})

  foreach(_lib IN LISTS _odbc_required_libs_names)
    find_library(_lib_path
      NAMES ${_lib}
      HINTS ${_odbc_lib_paths} # system paths or collected from ODBC_CONFIG
      PATH_SUFFIXES odbc)
    if(_lib_path)
      list(APPEND _odbc_required_libs_paths ${_lib_path})
    endif()
    unset(_lib_path CACHE)
  endforeach()
endif()

# Find library directory when ODBC_LIBRARY is set as a library name. For
# example, when looking for ODBC with ODBC_ROOT or CMAKE_PREFIX_PATH set.
if(NOT ODBC_LIBRARY_DIR AND ODBC_LIBRARY AND NOT IS_ABSOLUTE "${ODBC_LIBRARY}")
  find_library(ODBC_LIBRARY_DIR ${ODBC_LIBRARY} PATH_SUFFIXES odbc)
  if(ODBC_LIBRARY_DIR)
    cmake_path(GET ODBC_LIBRARY_DIR PARENT_PATH _parent)
    set_property(CACHE ODBC_LIBRARY_DIR PROPERTY VALUE ${_parent})
    unset(_parent)
  endif()
endif()

# Unset internal lists as no longer used
unset(_odbc_include_paths)
unset(_odbc_lib_paths)
unset(_odbc_lib_names)
unset(_odbc_required_libs_names)
unset(_odbc_config_names)

### Get version ###############################################################

# ODBC headers don't provide version. Try pkg-config or ODBC config.
if(PC_ODBC_VERSION AND ODBC_INCLUDE_DIR IN_LIST PC_ODBC_INCLUDE_DIRS)
  set(ODBC_VERSION ${PC_ODBC_VERSION})
elseif(ODBC_CONFIG)
  execute_process(
    COMMAND ${ODBC_CONFIG} --version
      OUTPUT_VARIABLE ODBC_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE result
      ERROR_QUIET
  )

  if(NOT result EQUAL 0 OR NOT ODBC_VERSION MATCHES [[[0-9]+\.[0-9.]+]])
    unset(ODBC_VERSION)
  endif()

  unset(result)
endif()

### Set result variables ######################################################
set(_odbc_required_vars ODBC_LIBRARY)
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
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
  HANDLE_VERSION_RANGE
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

      if(EXISTS "${ODBC_LIBRARY_DIR}")
        target_link_directories(ODBC::ODBC INTERFACE "${ODBC_LIBRARY_DIR}")
      endif()
    endif()
    set_target_properties(
      ODBC::ODBC
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${ODBC_INCLUDE_DIRS}"
    )

    if(_odbc_required_libs_paths)
      set_property(TARGET ODBC::ODBC APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES "${_odbc_required_libs_paths}")
    endif()

    if(ODBC_COMPILE_DEFINITIONS)
      target_compile_definitions(ODBC::ODBC INTERFACE ${ODBC_COMPILE_DEFINITIONS})
    endif()

    if(ODBC_COMPILE_OPTIONS)
      target_compile_options(ODBC::ODBC INTERFACE ${ODBC_COMPILE_OPTIONS})
    endif()

    if(ODBC_LINK_OPTIONS)
      target_link_options(ODBC::ODBC INTERFACE ${ODBC_LINK_OPTIONS})
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
    elseif(MINGW)
      set(ODBC_DRIVER "unixODBC")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
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
