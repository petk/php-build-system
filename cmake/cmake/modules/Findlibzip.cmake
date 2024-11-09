#[=============================================================================[
Find the libzip library.

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

Module defines the following `IMPORTED` target(s):

* `libzip::libzip` - The package library, if found.

Result variables:

* `libzip_FOUND` - Whether the package has been found.
* `libzip_INCLUDE_DIRS` - Include directories needed to use this package.
* `libzip_LIBRARIES` - Libraries needed to link to the package library.
* `libzip_VERSION` - Package version, if found.

Cache variables:

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.
* `HAVE_SET_MTIME`
* `HAVE_ENCRYPTION`
* `HAVE_LIBZIP_VERSION`

Hints:

The `libzip_ROOT` variable adds custom search path.
#]=============================================================================]

include(CheckLibraryExists)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  libzip
  PROPERTIES
    URL "https://libzip.org/"
    DESCRIPTION "Library for handling ZIP archives"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_libzip QUIET libzip)
endif()

find_path(
  libzip_INCLUDE_DIR
  NAMES zip.h
  PATHS ${PC_libzip_INCLUDE_DIRS}
  DOC "Directory containing libzip library headers"
)

if(NOT libzip_INCLUDE_DIR)
  string(APPEND _reason "zip.h not found. ")
endif()

find_library(
  libzip_LIBRARY
  NAMES zip
  PATHS ${PC_libzip_LIBRARY_DIRS}
  DOC "The path to the libzip library"
)

if(NOT libzip_LIBRARY)
  string(APPEND _reason "libzip library not found. ")
endif()

block(PROPAGATE libzip_VERSION)
  # Version in zipconf.h is available since libzip 1.4.0.
  if(libzip_INCLUDE_DIR AND EXISTS ${libzip_INCLUDE_DIR}/zipconf.h)
    set(regex [[^[ \t]*#[ \t]*define[ \t]+LIBZIP_VERSION[ \t]+"?([0-9.]+)"?[ \t]*$]])

    file(STRINGS ${libzip_INCLUDE_DIR}/zipconf.h results REGEX "${regex}")

    foreach(line ${results})
      if(line MATCHES "${regex}")
        set(libzip_VERSION "${CMAKE_MATCH_1}")
        break()
      endif()
    endforeach()
  endif()

  # If version was not found in the header, get version whether library was
  # found by pkgconf, otherwise the library was found elsewhere without pkgconf.
  if(NOT libzip_VERSION AND PC_libzip_VERSION)
    cmake_path(
      COMPARE
      "${libzip_INCLUDE_DIR}" EQUAL "${PC_libzip_INCLUDEDIR}"
      isEqual
    )

    if(isEqual)
      set(libzip_VERSION ${PC_libzip_VERSION})
    endif()
  endif()

  # Guess older version.
  if(NOT libzip_VERSION AND libzip_LIBRARY)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

      # zip_file_set_mtime is available with libzip 1.0.0.
      check_library_exists(
        "${libzip_LIBRARY}"
        zip_file_set_mtime
        ""
        HAVE_SET_MTIME
      )

      if(NOT HAVE_SET_MTIME)
        set(libzip_VERSION 0.11)
      else()
        set(libzip_VERSION 1.0)
      endif()

      # zip_file_set_encryption is available in libzip 1.2.0.
      check_library_exists(
        "${libzip_LIBRARY}"
        zip_file_set_encryption
        ""
        HAVE_ENCRYPTION
      )

      if(HAVE_ENCRYPTION)
        set(libzip_VERSION 1.2.0)
      endif()

      # zip_libzip_version is available in libzip 1.3.1.
      check_library_exists(
        "${libzip_LIBRARY}"
        zip_libzip_version
        ""
        HAVE_LIBZIP_VERSION
      )

      if(HAVE_LIBZIP_VERSION)
        set(libzip_VERSION 1.3.1)
      endif()
    cmake_pop_check_state()

    message(WARNING "The libzip version might not be correctly determined")
  endif()
endblock()

mark_as_advanced(libzip_INCLUDE_DIR libzip_LIBRARY)

find_package_handle_standard_args(
  libzip
  REQUIRED_VARS
    libzip_LIBRARY
    libzip_INCLUDE_DIR
  VERSION_VAR libzip_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT libzip_FOUND)
  return()
endif()

set(libzip_INCLUDE_DIRS ${libzip_INCLUDE_DIR})
set(libzip_LIBRARIES ${libzip_LIBRARY})

if(NOT TARGET libzip::libzip)
  add_library(libzip::libzip UNKNOWN IMPORTED)

  set_target_properties(
    libzip::libzip
    PROPERTIES
      IMPORTED_LOCATION "${libzip_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${libzip_INCLUDE_DIR}"
  )
endif()
