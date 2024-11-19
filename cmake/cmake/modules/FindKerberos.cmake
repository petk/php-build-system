#[=============================================================================[
Find the Kerberos library.

## Components

* Krb5
* GSSAPI

Module defines the following `IMPORTED` target(s):

* `Kerberos::Krb5` - The Kerberos library, if found.
* `Kerberos::GSSAPI` - The Kerberos GSSAPI component library, if found.

## Result variables

* `Kerberos_FOUND` - Whether the package has been found.
* `Kerberos_INCLUDE_DIRS` - Include directories needed to use this package.
* `Kerberos_LIBRARIES` - Libraries needed to link to the package library.
* `Kerberos_VERSION` - Package version, if found.

## Cache variables

* `Kerberos_INCLUDE_DIR` - Directory containing package library headers.
* `Kerberos_LIBRARY` - The path to the package library.
* `Kerberos_EXECUTABLE` - Path to the Kerberos command-line helper configuration
  script, if found.
* `Kerberos_GSSAPI_INCLUDE_DIR` -Directory containing GSSAPI library headers.
* `Kerberos_GSSAPI_LIBRARY` - The path to the GSSAPI library.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Kerberos
  PROPERTIES
    URL "https://web.mit.edu/kerberos/"
    DESCRIPTION "The Network Authentication Protocol"
)

set(_reason "")

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Kerberos QUIET krb5)
endif()

find_path(
  Kerberos_INCLUDE_DIR
  NAMES krb5.h
  HINTS ${PC_Kerberos_INCLUDE_DIRS}
  PATH_SUFFIXES krb5 mit-krb5
  DOC "Directory containing Kerberos library headers"
)

if(NOT Kerberos_INCLUDE_DIR)
  string(APPEND _reason "krb5.h not found. ")
endif()

find_library(
  Kerberos_LIBRARY
  NAMES krb5
  HINTS ${PC_Kerberos_LIBRARY_DIRS}
  DOC "The path to the Kerberos library"
)

if(NOT Kerberos_LIBRARY)
  string(APPEND _reason "Kerberos library not found. ")
endif()

if(Kerberos_LIBRARY AND Kerberos_INCLUDE_DIR)
  set(Kerberos_Krb5_FOUND TRUE)
endif()

find_program(
  Kerberos_EXECUTABLE
  NAMES krb5-config
  DOC "Path to the Kerberos command-line helper configuration script, if found."
)

# Get version.
block(PROPAGATE Kerberos_VERSION)
  # Kerberos headers don't provide version. Try pkg-config.
  if(
    PC_Kerberos_VERSION
    AND Kerberos_INCLUDE_DIR IN_LIST PC_Kerberos_INCLUDE_DIRS
  )
    set(Kerberos_VERSION ${PC_Kerberos_VERSION})
  endif()

  # Try with krb5-config script.
  if(NOT Kerberos_VERSION AND Kerberos_EXECUTABLE)
    execute_process(
      COMMAND "${Kerberos_EXECUTABLE}" --version
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
      OUTPUT_QUIET
    )

    if(version MATCHES [[ ([0-9]\.[0-9.]+)]])
      set(Kerberos_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

# Find Kerberos GSSAPI component.
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Kerberos_GSSAPI QUIET krb5-gssapi)
endif()

find_path(
  Kerberos_GSSAPI_INCLUDE_DIR
  NAMES gssapi/gssapi_krb5.h
  HINTS ${PC_Kerberos_GSSAPI_INCLUDE_DIRS}
  PATH_SUFFIXES mit-krb5
  DOC "Directory containing Kerberos GSSAPI library headers"
)

find_library(
  Kerberos_GSSAPI_LIBRARY
  NAMES gssapi_krb5
  HINTS ${PC_Kerberos_GSSAPI_LIBRARY_DIRS}
  PATH_SUFFIXES mit-krb5
  DOC "The path to the Kerberos GSSAPI library"
)

if(Kerberos_GSSAPI_INCLUDE_DIR AND Kerberos_GSSAPI_LIBRARY)
  set(Kerberos_GSSAPI_FOUND TRUE)
elseif("GSSAPI" IN_LIST Kerberos_FIND_COMPONENTS)
  string(APPEND _reason "Kerberos GSSAPI library (gssapi-krb5) not found. ")
endif()

mark_as_advanced(
  Kerberos_EXECUTABLE
  Kerberos_GSSAPI_INCLUDE_DIR
  Kerberos_GSSAPI_LIBRARY
  Kerberos_INCLUDE_DIR
  Kerberos_LIBRARY
)

find_package_handle_standard_args(
  Kerberos
  REQUIRED_VARS
    Kerberos_LIBRARY
    Kerberos_INCLUDE_DIR
  VERSION_VAR Kerberos_VERSION
  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Kerberos_FOUND)
  return()
endif()

set(Kerberos_INCLUDE_DIRS ${Kerberos_INCLUDE_DIR})

if(Kerberos_GSSAPI_INCLUDE_DIR)
  list(APPEND Kerberos_INCLUDE_DIRS ${Kerberos_GSSAPI_INCLUDE_DIR})
endif()

set(Kerberos_LIBRARIES ${Kerberos_LIBRARY})

if(Kerberos_GSSAPI_LIBRARY)
  list(APPEND Kerberos_LIBRARIES ${Kerberos_GSSAPI_LIBRARY})
endif()

if(NOT TARGET Kerberos::Krb5)
  add_library(Kerberos::Krb5 UNKNOWN IMPORTED)

  set_target_properties(
    Kerberos::Krb5
    PROPERTIES
      IMPORTED_LOCATION "${Kerberos_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Kerberos_INCLUDE_DIR}"
  )
endif()

if(Kerberos_GSSAPI_FOUND AND NOT TARGET Kerberos::GSSAPI)
  add_library(Kerberos::GSSAPI UNKNOWN IMPORTED)

  set_target_properties(
    Kerberos::GSSAPI
    PROPERTIES
      IMPORTED_LOCATION "${Kerberos_GSSAPI_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Kerberos_GSSAPI_INCLUDE_DIR}"
  )
endif()
