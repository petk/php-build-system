#[=============================================================================[
Find PHP.

Components:

  PHP
    The PHP, general-purpose scripting language component.
  PHP-Embed
    The PHP Embed SAPI component - A lightweight SAPI to embed PHP into
    application using C bindings.

Module defines the following IMPORTED target(s):

  PHP::PHP
    The PHP package library, if found.
  PHP:Embed
    The PHP embed SAPI, if found.

Result variables:

  PHP_FOUND
    Whether the package has been found.
  PHP_INCLUDE_DIRS
    Include directories needed to use this package.
  PHP_LIBRARIES
    Libraries needed to link to the package library.
  PHP_VERSION
    Package version, if found.
  PHP_INSTALL_INCLUDEDIR
    Relative path to the CMAKE_PREFIX_INSTALL containing PHP headers.

Cache variables:

  PHP_CONFIG_EXECUTABLE
    Path to the php-config development helper tool.
  PHP_INCLUDE_DIR
    Directory containing PHP headers.
  PHP_Embed_LIBRARY
    The path to the PHP Embed library.
  PHP_Embed_INCLUDE_DIR
    Directory containing PHP Embed header(s).

Hints:

  The PHP_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  PHP
  PROPERTIES
    URL "https://www.php.net"
    DESCRIPTION "General-purpose scripting language"
)

set(_reason "")

# Find php-config tool.
find_program(
  PHP_CONFIG_EXECUTABLE
  NAMES php-config
  DOC "Path to the php-config development helper command-line tool"
)

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_PHP QUIET php)

# Get PHP include directories.
if(PHP_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${PHP_CONFIG_EXECUTABLE}" --includes
    OUTPUT_VARIABLE PHP_INCLUDE_DIRS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if(PHP_INCLUDE_DIRS)
    string(REPLACE "-I" "" PHP_INCLUDE_DIRS "${PHP_INCLUDE_DIRS}")
    string(REPLACE " " ";" PHP_INCLUDE_DIRS "${PHP_INCLUDE_DIRS}")
  endif()
endif()

find_path(
  PHP_INCLUDE_DIR
  NAMES main/php_config.h
  PATHS
    ${PC_PHP_INCLUDE_DIRS}
    ${PHP_INCLUDE_DIRS}
  DOC "Directory containing PHP main binding headers"
)

if(NOT PHP_INCLUDE_DIR)
  string(APPEND _reason "main/php_config.h not found. ")
endif()

# Get relative PHP include directory path.
if(PHP_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${PHP_CONFIG_EXECUTABLE}" --include-dir
    OUTPUT_VARIABLE PHP_INSTALL_INCLUDEDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  execute_process(
    COMMAND "${PHP_CONFIG_EXECUTABLE}" --prefix
    OUTPUT_VARIABLE PHP_INSTALL_PREFIX
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  cmake_path(
    RELATIVE_PATH
    PHP_INSTALL_INCLUDEDIR
    BASE_DIRECTORY "${PHP_INSTALL_PREFIX}"
  )
elseif(PC_PHP_PREFIX)
  cmake_path(
    RELATIVE_PATH
    PHP_INSTALL_INCLUDEDIR
    BASE_DIRECTORY "${PHP_INSTALL_PREFIX}"
  )
endif()

pkg_check_modules(PC_PHP_Embed QUIET php-embed)

find_library(
  PHP_Embed_LIBRARY
  NAMES php
  PATHS ${PC_PHP_Embed_LIBRARY_DIRS}
  DOC "The path to the libphp embed library"
)

find_path(
  PHP_Embed_INCLUDE_DIR
  NAMES sapi/embed/php_embed.h
  PATHS
    ${PC_PHP_Embed_INCLUDE_DIRS}
    ${PHP_INCLUDE_DIRS}
  DOC "Directory containing PHP Embed SAPI header(s)"
)

if(PHP_Embed_LIBRARY AND PHP_Embed_INCLUDE_DIR)
  set(PHP_Embed_FOUND TRUE)
elseif("Embed" IN_LIST PHP_FIND_COMPONENTS)
  if(NOT PHP_Embed_INCLUDE_DIR)
    string(APPEND _reason "sapi/embed/php_embed.h not found. ")
  endif()

  if(NOT PHP_Embed_LIBRARY)
    string(APPEND _reason "PHP library (libphp) not found. ")
  endif()
endif()

# Get version.
block(PROPAGATE PHP_VERSION)
  if(PHP_INCLUDE_DIR AND EXISTS ${PHP_INCLUDE_DIR}/main/php_version.h)
    file(
      STRINGS
      ${PHP_INCLUDE_DIR}/main/php_version.h
      php_version
      REGEX [[^#[ \t]*define[ \t]+PHP_VERSION[ \t]+"[0-9]+\.[0-9]+\.[0-9]+.*"[ \t]*$]]
      LIMIT_COUNT 1
    )
    string(
      REGEX MATCH
      [[([0-9]+\.[0-9]+\.[0-9]+.*)"[ \t]*$]]
      _
      "${php_version}"
    )
    if(CMAKE_MATCH_1)
      set(PHP_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  # Try pkgconf version, if found.
  if(NOT PHP_VERSION AND PC_PHP_VERSION)
    cmake_path(
      COMPARE
      "${PC_PHP_INCLUDEDIR}" EQUAL "${PHP_INCLUDE_DIR}"
      isEqual
    )

    if(isEqual)
      set(PHP_VERSION ${PC_PHP_VERSION})
    endif()
  endif()
endblock()

mark_as_advanced(
  PHP_CONFIG_EXECUTABLE
  PHP_INCLUDE_DIR
  PHP_Embed_LIBRARY
  PHP_Embed_INCLUDE_DIR
)

find_package_handle_standard_args(
  PHP
  REQUIRED_VARS
    PHP_INCLUDE_DIR
  VERSION_VAR PHP_VERSION
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT PHP_FOUND)
  return()
endif()

set(PHP_LIBRARIES ${PHP_Embed_LIBRARY})

if(NOT TARGET PHP::PHP)
  add_library(PHP::PHP UNKNOWN IMPORTED)

  set_target_properties(
    PHP::PHP
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${PHP_INCLUDE_DIRS}"
  )
endif()

if(PHP_Embed_FOUND AND NOT TARGET PHP::Embed)
  add_library(PHP::Embed UNKNOWN IMPORTED)

  set_target_properties(
    PHP::Embed
    PROPERTIES
      IMPORTED_LOCATION "${PHP_Embed_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${PHP_Embed_INCLUDE_DIR}"
  )
endif()
