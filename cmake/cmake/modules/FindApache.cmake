#[=============================================================================[
# FindApache

Find the Apache packages and tools.

The Apache development package usually contains Apache header files, the `apr`
(Apache Portable Runtime) library and its headers, `apr` config command-line
tool, and the `apxs` command-line tool.

Module defines the following `IMPORTED` target(s):

* `Apache::Apache` - The package library, if found.

## Result variables

* `Apache_FOUND` - Whether the package has been found.
* `Apache_INCLUDE_DIRS` - Include directories needed to use this package.
* `Apache_LIBRARIES` - Libraries needed to link to the package library.
* `Apache_VERSION` - Package version, if found.
* `Apache_THREADED` - Whether Apache requires thread safety.
* `Apache_LIBEXECDIR` - Path to the directory containing all Apache modules and
  `httpd.exp` file (list of exported symbols).

## Cache variables

* `Apache_APXS_EXECUTABLE` - Path to the APache eXtenSion tool command-line tool
  (`apxs`).
* `Apache_APXS_DEFINITIONS` - A list of compile definitions (`-D`) from the
  `apxs -q CFLAGS` query string.
* `Apache_APR_CONFIG_EXECUTABLE` - Path to the `apr` library command-line
  configuration tool.
* `Apache_APR_CPPFLAGS` - A list of C preprocessor flags for the `apr` library.
* `Apache_APU_CONFIG_EXECUTABLE` - Path to the Apache Portable Runtime Utilities
  config command-line tool.
* `Apache_EXECUTABLE` - Path to the Apache command-line server program.
* `Apache_INCLUDE_DIR` - Directory containing package library headers.
* `Apache_APR_INCLUDE_DIR` - Directory containing `apr` library headers.
* `Apache_APR_LIBRARY` - The path to the `apr` library.
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

find_program(
  Apache_APXS_EXECUTABLE
  NAMES apxs apxs2
  DOC "Path to the APache eXtenSion tool"
)
mark_as_advanced(Apache_APXS_EXECUTABLE)

if(NOT Apache_APXS_EXECUTABLE)
  string(APPEND _reason "apxs tool not found. ")
else()
  # Sanity check for apxs.
  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q CFLAGS
    OUTPUT_VARIABLE Apache_APXS_DEFINITIONS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    RESULT_VARIABLE _result
  )

  if(_result STREQUAL "0")
    set(_Apache_APXS_SANITY_CHECK TRUE)

    # Get all compile definitions from the above CFLAGS result if found.
    separate_arguments(
      Apache_APXS_DEFINITIONS
      NATIVE_COMMAND
      "${Apache_APXS_DEFINITIONS}"
    )
    list(FILTER Apache_APXS_DEFINITIONS INCLUDE REGEX "^-D")
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

  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q LIBEXECDIR
    OUTPUT_VARIABLE Apache_LIBEXECDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q TARGET
    OUTPUT_VARIABLE _Apache_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q SBINDIR
    OUTPUT_VARIABLE _Apache_SBINDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  execute_process(
    COMMAND "${Apache_APXS_EXECUTABLE}" -q INCLUDEDIR
    OUTPUT_VARIABLE _Apache_APXS_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

################################################################################
# APR.
################################################################################

find_program(
  Apache_APR_CONFIG_EXECUTABLE
  NAMES apr-config apr-1-config
  HINTS ${_Apache_APR_BINDIR}
  DOC "Path to the apr library command-line tool for retrieving metainformation"
)
mark_as_advanced(Apache_APR_CONFIG_EXECUTABLE)

block()
  if(NOT Apache_APR_CONFIG_EXECUTABLE AND Apache_APXS_EXECUTABLE)
    execute_process(
      COMMAND "${Apache_APXS_EXECUTABLE}" -q APR_CONFIG
      OUTPUT_VARIABLE path
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if(CMAKE_VERSION VERSION_LESS 3.29)
      if(EXISTS ${path})
        set_property(CACHE Apache_APR_CONFIG_EXECUTABLE PROPERTY VALUE ${path})
      endif()
    elseif(IS_EXECUTABLE ${path})
      set_property(CACHE Apache_APR_CONFIG_EXECUTABLE PROPERTY VALUE ${path})
    endif()
  endif()
endblock()

if(Apache_APR_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${Apache_APR_CONFIG_EXECUTABLE}" --cppflags
    OUTPUT_VARIABLE Apache_APR_CPPFLAGS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  separate_arguments(
    Apache_APR_CPPFLAGS
    NATIVE_COMMAND
    "${Apache_APR_CPPFLAGS}"
  )

  execute_process(
    COMMAND "${Apache_APR_CONFIG_EXECUTABLE}" --includedir
    OUTPUT_VARIABLE _Apache_APR_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_Apache_APR QUIET apr-1)
endif()

find_path(
  Apache_APR_INCLUDE_DIR
  NAMES apr.h
  HINTS
    ${PC_Apache_APR_INCLUDE_DIRS}
    ${_Apache_APR_INCLUDE_DIR}
    ${_Apache_APU_INCLUDE_DIR}
  PATH_SUFFIXES apr-1
  DOC "Directory containing apr library headers"
)

if(NOT Apache_APR_INCLUDE_DIR)
  string(APPEND _reason "apr.h not found. ")
endif()

find_library(
  Apache_APR_LIBRARY
  NAMES apr-1
  HINTS ${PC_Apache_APR_LIBRARY_DIRS}
  DOC "The path to the apr library"
)
mark_as_advanced(Apache_APR_LIBRARY)

if(NOT Apache_APR_LIBRARY)
  string(APPEND _reason "Apache apr library not found. ")
endif()

################################################################################
# APU.
################################################################################

find_program(
  Apache_APU_CONFIG_EXECUTABLE
  NAMES apu-config apu-1-config
  HINTS ${_Apache_APU_BINDIR}
  DOC "Path to the Apache Portable Runtime Utilities config command-line tool"
)
mark_as_advanced(Apache_APU_CONFIG_EXECUTABLE)

block()
  if(NOT Apache_APU_CONFIG_EXECUTABLE AND Apache_APXS_EXECUTABLE)
    execute_process(
      COMMAND "${Apache_APXS_EXECUTABLE}" -q APU_CONFIG
      OUTPUT_VARIABLE path
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if(CMAKE_VERSION VERSION_LESS 3.29)
      if(EXISTS ${path})
        set_property(CACHE Apache_APU_CONFIG_EXECUTABLE PROPERTY VALUE ${path})
      endif()
    elseif(IS_EXECUTABLE ${path})
      set_property(CACHE Apache_APU_CONFIG_EXECUTABLE PROPERTY VALUE ${path})
    endif()
  endif()
endblock()

if(Apache_APU_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${Apache_APU_CONFIG_EXECUTABLE}" --includedir
    OUTPUT_VARIABLE _Apache_APU_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()

################################################################################
# Apache.
################################################################################

find_program(
  Apache_EXECUTABLE
  NAMES ${_Apache_NAME} apache2
  HINTS ${_Apache_SBINDIR}
  DOC "Path to the Apache HTTP server command-line utility"
)
mark_as_advanced(Apache_EXECUTABLE)

if(NOT Apache_EXECUTABLE)
  string(APPEND _reason "Apache HTTP server command-line utility not found. ")
endif()

find_path(
  Apache_INCLUDE_DIR
  NAMES httpd.h
  PATH_SUFFIXES apache2
  HINTS ${_Apache_APXS_INCLUDE_DIR}
  DOC "Directory containing Apache headers"
)
mark_as_advanced(Apache_INCLUDE_DIR)

if(NOT Apache_INCLUDE_DIR)
  string(APPEND _reason "httpd.h not found. ")
endif()

# Get Apache version.
block(PROPAGATE Apache_VERSION)
  if(EXISTS ${Apache_INCLUDE_DIR}/ap_release.h)
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

  # If Apache headers don't provide version, try apxs command-line tool.
  # The 'apxs -q' HTTPD_VERSION variable was added in Apache 2.4.17.
  if(NOT Apache_VERSION AND Apache_APXS_EXECUTABLE)
    execute_process(
      COMMAND "${Apache_APXS_EXECUTABLE}" -q HTTPD_VERSION
      OUTPUT_VARIABLE Apache_VERSION
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
  endif()

  # If version is still not found, try Apache command-line tool.
  if(NOT Apache_VERSION AND Apache_EXECUTABLE)
    execute_process(
      COMMAND "${Apache_EXECUTABLE}" -v
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    if(version MATCHES [[ Apache/([0-9]+\.[0-9.]+)]])
      set(Apache_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

################################################################################
# Check if Apache requires thread safety.
################################################################################

block(PROPAGATE Apache_THREADED)
  set(Apache_THREADED FALSE)

  if(Apache_EXECUTABLE)
    execute_process(
      COMMAND "${Apache_EXECUTABLE}" -V
      OUTPUT_VARIABLE result
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    if(result MATCHES " threaded:.*yes")
      set(Apache_THREADED TRUE)
    endif()
  endif()
endblock()

################################################################################
# Handle package arguments.
################################################################################

find_package_handle_standard_args(
  Apache
  REQUIRED_VARS
    Apache_APXS_EXECUTABLE
    _Apache_APXS_SANITY_CHECK
    Apache_INCLUDE_DIR
    Apache_APR_INCLUDE_DIR
    Apache_EXECUTABLE
  VERSION_VAR Apache_VERSION
  HANDLE_VERSION_RANGE
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

  target_compile_definitions(
    Apache::Apache
    INTERFACE
      ${Apache_APR_CPPFLAGS}
      ${Apache_APXS_DEFINITIONS}
  )
endif()
