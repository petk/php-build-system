#[=============================================================================[
Find the Kerberos library.

Components:

  GSSAPI

  Krb5

Module defines the following IMPORTED targets:

  Kerberos::Kerberos
    The Kerberos library if found.

Result variables:

  Kerberos_FOUND
    Whether Kerberos library has been found.
  Kerberos_INCLUDE_DIRS
    A list of include directories for using Kerberos library.
  Kerberos_LIBRARIES
    A list of libraries for linking when using Kerberos library.
  Kerberos_VERSION
    Version string of Kerberos library.
  Kerberos_EXECUTABLE
    Kerberos command-line helper configuration script if found.

Hints:

  TODO: The Kerberos_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Kerberos PROPERTIES
  URL "https://web.mit.edu/kerberos/"
  DESCRIPTION "The Network Authentication Protocol"
)

set(_reason_failure_message)

find_path(Kerberos_INCLUDE_DIRS krb5.h PATH_SUFFIXES krb5 mit-krb5)

if(NOT Kerberos_INCLUDE_DIRS)
  string(
    APPEND _reason_failure_message
    "\n    krb5.h not found."
  )
endif()

find_library(Kerberos_LIBRARIES NAMES krb5 DOC "The Kerberos library")

if(NOT Kerberos_LIBRARIES)
  string(
    APPEND _reason_failure_message
    "\n    Kerberos library not found. Please install Kerberos library."
  )
endif()

mark_as_advanced(Kerberos_LIBRARIES Kerberos_INCLUDE_DIRS)

find_program(Kerberos_EXECUTABLE krb5-config)
if(Kerberos_EXECUTABLE)
  execute_process(
    COMMAND ${Kerberos_EXECUTABLE} --version
    OUTPUT_VARIABLE _kerberos_version_string
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    OUTPUT_QUIET
  )

  string(REGEX MATCH " ([0-9]\.[0-9.]+) " _ "${_kerberos_version_string}")

  if(CMAKE_MATCH_1)
    set(Kerberos_VERSION "${CMAKE_MATCH_1}")
    set(_kerberos_version_argument VERSION_VAR Kerberos_VERSION)
  endif()
endif()

if(Kerberos_LIBRARIES AND Kerberos_INCLUDE_DIRS)
  set(Kerberos_Krb5_FOUND TRUE)
endif()

find_path(Kerberos_GSSAPI_INCLUDE_DIRS gssapi/gssapi_krb5.h PATH_SUFFIXES mit-krb5)
if(Kerberos_GSSAPI_INCLUDE_DIRS)
  list(APPEND Kerberos_INCLUDE_DIRS ${Kerberos_GSSAPI_INCLUDE_DIRS})
endif()

find_library(
  Kerberos_GSSAPI_LIBRARIES
  NAMES gssapi_krb5
  DOC "Kerberos GSSAPI library"
)

if(Kerberos_GSSAPI_LIBRARIES)
  list(APPEND Kerberos_LIBRARIES ${Kerberos_GSSAPI_LIBRARIES})
endif()

message(STATUS "Requested Kerberos components: ${Kerberos_FIND_COMPONENTS}")

if(Kerberos_GSSAPI_LIBRARIES AND Kerberos_GSSAPI_INCLUDE_DIRS)
  set(Kerberos_GSSAPI_FOUND TRUE)
elseif("GSSAPI" IN_LIST Kerberos_FIND_COMPONENTS)
  string(
    APPEND _reason_failure_message
    "\n    Kerberos GSSAPI library not found. Please install Kerberos GSSAPI "
    "library (gssapi-krb5)."
  )
endif()

find_package_handle_standard_args(
  Kerberos
  REQUIRED_VARS Kerberos_LIBRARIES Kerberos_INCLUDE_DIRS
  ${_kerberos_version_argument}
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)
unset(_kerberos_version_argument)

if(Kerberos_FOUND AND NOT TARGET Kerberos::Kerberos)
  add_library(Kerberos::Kerberos INTERFACE IMPORTED)

  set_target_properties(Kerberos::Kerberos PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Kerberos_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${Kerberos_LIBRARIES}"
  )
endif()
