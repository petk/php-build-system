#[=============================================================================[
Find the Apache packages and tools.

The Apache development package usualy contains Apache header files, the apr
(Apache Portable Runtime) library and its headers, apr config command-line tool,
and apxs command-line tool.

Module defines the following IMPORTED target(s):

  Apache::Apache
    The package library, if found.

Result variables:

  Apache_FOUND
    Whether the package has been found.
  Apache_INCLUDE_DIRS
    Include directories needed to use this package.
  Apache_LIBRARIES
    Libraries needed to link to the package library.
  Apache_VERSION
    Package version, if found.

Cache variables:

  Apache_APXS_EXECUTABLE
    Path to the APache eXtenSion tool command-line utility.
  Apache_APR_CONFIG_EXECUTABLE
    Path to the apr library command-line configuration utility.
  Apache_APU_CONFIG_EXECUTABLE
    Path to the Apache Portable Runtime Utilities config command-line utility.
  Apache_EXECUTABLE
    Path to the Apache command-line server program.
  Apache_INCLUDE_DIR
    Directory containing package library headers.
  Apache_APR_INCLUDE_DIR
    Directory containing apr library headers.
  Apache_APR_LIBRARY
    The path to the apr library.

Hints:

  The Apache_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Apache
  PROPERTIES
    URL "https://httpd.apache.org/"
    DESCRIPTION "The Apache HTTP Server"
)

set(_reason "")

################################################################################
# APXS.
################################################################################

find_program(Apache_APXS_EXECUTABLE NAMES apxs apxs2)

if(NOT Apache_APXS_EXECUTABLE)
  string(APPEND _reason "apxs tool not found. ")
else()
  # Sanity check for apxs.
  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q CFLAGS
    OUTPUT_VARIABLE _Apache_APXS_CFLAGS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    RESULT_VARIABLE _result
  )

  if(result STREQUAL "0")
    set(_Apache_APXS_SANITY_CHECK TRUE)
  else()
    string(
      APPEND
      _reason
      "The apxs sanity check failed. Check if Perl is installed and Apache is "
      "built using the --enable-so option."
    )
  endif()
  unset(_result)

  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q APR_BINDIR
    OUTPUT_VARIABLE _Apache_APR_BINDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q APU_BINDIR
    OUTPUT_VARIABLE _Apache_APU_BINDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

################################################################################
# APR.
################################################################################

find_program(
  Apache_APR_CONFIG_EXECUTABLE
  NAMES apr-1-config apr-config
  PATHS ${_Apache_APR_BINDIR}
)

if(Apache_APR_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${Apache_APR_CONFIG_EXECUTABLE}" --cppflags
    OUTPUT_VARIABLE _Apache_APR_CPPFLAGS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  execute_process(
    COMMAND "${Apache_APR_CONFIG_EXECUTABLE}" --includedir
    OUTPUT_VARIABLE _Apache_APR_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

# Find the apr library (Apache portable runtime).
# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Apache_APR QUIET apr-1)

find_path(
  Apache_APR_INCLUDE_DIR
  NAMES apr.h
  PATHS
    ${PC_Apache_APR_INCLUDE_DIRS}
    ${_Apache_APR_INCLUDE_DIR}
  PATH_SUFFIXES apr-1
  DOC "Directory containing apr library headers"
)

if(NOT Apache_APR_INCLUDE_DIR)
  string(APPEND _reason "apr.h not found. ")
endif()

find_library(
  Apache_APR_LIBRARY
  NAMES apr-1
  PATHS ${PC_Apache_APR_LIBRARY_DIRS}
  DOC "The path to the apr library"
)

if(NOT Apache_APR_LIBRARY)
  string(APPEND _reason "Apache apr library not found. ")
endif()

################################################################################
# APU.
################################################################################

find_program(
  Apache_APU_CONFIG_EXECUTABLE
  NAMES apu-1-config apu-config
  PATHS ${_Apache_APU_BINDIR}
)

################################################################################
# Apache.
################################################################################

find_program(Apache_EXECUTABLE NAMES apache2)

execute_process(
  COMMAND "${Apache_APXS_EXECUTABLE}" -q INCLUDEDIR
  OUTPUT_VARIABLE _Apache_APXS_INCLUDE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
)

find_path(
  Apache_INCLUDE_DIR
  NAMES httpd.h
  PATH_SUFFIXES apache2
  PATHS ${_Apache_APXS_INCLUDE_DIR}
  DOC "Directory containing Apache headers"
)

if(NOT Apache_INCLUDE_DIR)
  string(APPEND _reason "httpd.h not found. ")
endif()

# Get Apache version.
block(PROPAGATE Apache_VERSION)
  if(Apache_INCLUDE_DIR AND EXISTS ${Apache_INCLUDE_DIR}/ap_release.h)
    file(
      STRINGS
      ${Apache_INCLUDE_DIR}/ap_release.h
      results
      REGEX
      "^#[ \t]*define[ \t]+AP_SERVER_(MAJORVERSION_NUMBER|MINORVERSION_NUMBER|PATCHLEVEL_NUMBER|_DEVBUILD_BOOLEAN)?[ \t]+[0-9]+[ \t]*$"
    )

    foreach(line ${results})
      foreach(item MAJORVERSION_NUMBER MINORVERSION_NUMBER PATCHLEVEL_NUMBER)
        if(line MATCHES "^#[ \t]*define[ \t]+AP_SERVER_${item}?[ \t]+([0-9])+[ \t]*$")
          if(DEFINED Apache_VERSION)
            string(APPEND Apache_VERSION ".${CMAKE_MATCH_1}")
          else()
            set(Apache_VERSION "${CMAKE_MATCH_1}")
          endif()
        endif()
      endforeach()

      # Append -dev if development release is found.
      if(line MATCHES "^#[ \t]*define[ \t]+AP_SERVER_DEVBUILD_BOOLEAN[ \t]+([0-9]+)[ \t]*$")
        if(DEFINED Apache_VERSION AND DEFINED CMAKE_MATCH_1 AND NOT CMAKE_MATCH_1 STREQUAL "0")
          string(APPEND Apache_VERSION "-dev")
        endif()
      endif()
    endforeach()
  endif()

  # If Apache headers don't provide version, try Apache command-line tool.
  if(Apache_EXECUTABLE)
    execute_process(
      COMMAND "${Apache_EXECUTABLE}" -v
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    string(REGEX MATCH " Apache/([0-9]\.[0-9.]+\.[0-9]+) " _ "${version}")

    if(CMAKE_MATCH_1)
      set(Apache_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

mark_as_advanced(
  Apache_APXS_EXECUTABLE
  Apache_INCLUDE_DIR
  Apache_APR_LIBRARY
)

find_package_handle_standard_args(
  Apache
  REQUIRED_VARS
    Apache_APXS_EXECUTABLE
    _Apache_APXS_SANITY_CHECK
    Apache_INCLUDE_DIR
    Apache_APR_INCLUDE_DIR
  VERSION_VAR Apache_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Apache_FOUND)
  return()
endif()

set(Apache_INCLUDE_DIRS ${Apache_INCLUDE_DIR} ${Apache_APR_INCLUDE_DIR})
set(Apache_LIBRARIES ${Apache_APR_LIBRARY})

if(NOT TARGET Apache::Apache)
  add_library(Apache::Apache INTERFACE IMPORTED)

  set_target_properties(
    Apache::Apache
    PROPERTIES
      INTERFACE_LINK_LIBRARIES "${Apache_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${Apache_INCLUDE_DIRS}"
  )

  if(_Apache_APR_CPPFLAGS)
    target_compile_definitions(
      Apache::Apache
      INTERFACE "${_Apache_APR_CFLAGS}"
    )
  endif()
endif()
