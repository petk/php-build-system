#[=============================================================================[
# Findlibzip

Finds the libzip library:

```cmake
find_package(libzip)
```

This is a helper in case system doesn't have the libzip's Config find module
yet. It seems that libzip find module provided by the library requires also
zip tools installed on the system.

## Imported targets

This module defines the following imported targets:

* `libzip::libzip` - The package library, if found.

## Result variables

* `libzip_FOUND` - Whether the package has been found.
* `libzip_INCLUDE_DIRS` - Include directories needed to use this package.
* `libzip_LIBRARIES` - Libraries needed to link to the package library.
* `libzip_VERSION` - Package version, if found.

## Cache variables

* `libzip_INCLUDE_DIR` - Directory containing package library headers.
* `libzip_LIBRARY` - The path to the package library.
* `HAVE_SET_MTIME`
* `HAVE_ENCRYPTION`
* `HAVE_LIBZIP_VERSION`

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(libzip)
target_link_libraries(example PRIVATE libzip::libzip)
```
#]=============================================================================]

include(CheckSymbolExists)
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

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_libzip QUIET libzip)
endif()

find_path(
  libzip_INCLUDE_DIR
  NAMES zip.h
  HINTS ${PC_libzip_INCLUDE_DIRS}
  DOC "Directory containing libzip library headers"
)

if(NOT libzip_INCLUDE_DIR)
  string(APPEND _reason "zip.h not found. ")
endif()

find_library(
  libzip_LIBRARY
  NAMES zip
  HINTS ${PC_libzip_LIBRARY_DIRS}
  DOC "The path to the libzip library"
)

if(NOT libzip_LIBRARY)
  string(APPEND _reason "libzip library not found. ")
endif()

block(PROPAGATE libzip_VERSION)
  # Version in zipconf.h is available since libzip 1.4.0.
  if(EXISTS ${libzip_INCLUDE_DIR}/zipconf.h)
    set(regex "^[ \t]*#[ \t]*define[ \t]+LIBZIP_VERSION[ \t]+\"?([^\"]+)\"?[ \t]*$")

    file(STRINGS ${libzip_INCLUDE_DIR}/zipconf.h result REGEX "${regex}")

    if(result MATCHES "${regex}")
      set(libzip_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT libzip_VERSION
    AND PC_libzip_VERSION
    AND libzip_INCLUDE_DIR IN_LIST PC_libzip_INCLUDE_DIRS
  )
    set(libzip_VERSION ${PC_libzip_VERSION})
  endif()

  # Determine libzip older version heuristically.
  if(NOT libzip_VERSION AND libzip_INCLUDE_DIR AND libzip_LIBRARY)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_INCLUDES ${libzip_INCLUDE_DIR})
      set(CMAKE_REQUIRED_LIBRARIES ${libzip_LIBRARY})
      set(CMAKE_REQUIRED_QUIET TRUE)

      # zip_file_set_mtime is available with libzip 1.0.0.
      check_symbol_exists(zip_file_set_mtime zip.h HAVE_SET_MTIME)

      if(NOT HAVE_SET_MTIME)
        set(libzip_VERSION 0.11)
      else()
        set(libzip_VERSION 1.0)
      endif()

      # zip_file_set_encryption is available in libzip 1.2.0.
      check_symbol_exists(zip_file_set_encryption zip.h HAVE_ENCRYPTION)

      if(HAVE_ENCRYPTION)
        set(libzip_VERSION 1.2.0)
      endif()

      # zip_libzip_version is available in libzip 1.3.1.
      check_symbol_exists(zip_libzip_version zip.h HAVE_LIBZIP_VERSION)

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
      INTERFACE_INCLUDE_DIRECTORIES "${libzip_INCLUDE_DIRS}"
  )
endif()
