#[=============================================================================[
# FindPHP

Find PHP.

Components:

* `php` - The PHP, general-purpose scripting language, component for building
  extensions.
* `embed` - The PHP Embed SAPI component - A lightweight SAPI to embed PHP into
  application using C bindings.

## Imported targets

This module defines the following imported targets:

* `PHP::php` - The PHP package `IMPORTED` target, if found.
* `PHP::embed` - The PHP embed SAPI, if found.

## Result variables

* `PHP_FOUND` - Boolean indicating whether the package is found.
* `PHP_INCLUDE_DIRS` - Include directories needed to use this package.
* `PHP_LIBRARIES` - Libraries needed to link to the package library.
* `PHP_VERSION` - The version of package found.
* `PHP_INSTALL_INCLUDEDIR` - Relative path to the `CMAKE_PREFIX_INSTALL`
  containing PHP headers.
* `PHP_EXTENSION_DIR` - Path to the directory where shared extensions are
  installed.
* `PHP_API_VERSION` - Internal PHP API version number (`PHP_API_VERSION` in
  `<main/php.h>`).
* `PHP_ZEND_MODULE_API` - Internal API version number for PHP extensions
  (`ZEND_MODULE_API_NO` in `<Zend/zend_modules.h>`). These are most common PHP
  extensions either built-in or loaded dynamically with the `extension` INI
  directive.
* `PHP_ZEND_EXTENSION_API` - Internal API version number for Zend extensions
  (`ZEND_EXTENSION_API_NO` in `<Zend/zend_extensions.h>`). Zend extensions are,
  for example, opcache, debuggers, profilers and similar advanced extensions.
  They are either built-in or dynamically loaded with the `zend_extension` INI
  directive.

## Cache variables

* `PHP_CONFIG_EXECUTABLE` - Path to the php-config development helper tool.
* `PHP_INCLUDE_DIR` - Directory containing PHP headers.
* `PHP_EMBED_LIBRARY` - The path to the PHP Embed library.
* `PHP_EMBED_INCLUDE_DIR` - Directory containing PHP Embed header(s).

## Usage

```cmake
# CMakeLists.txt

# Find PHP
find_package(PHP)

# Find PHP embed component
find_package(PHP COMPONENTS embed)

# Override where to find PHP
set(PHP_ROOT /path/to/php/installation)
find_package(PHP)
```
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

################################################################################
# php-config
################################################################################

# Find php-config tool.
find_program(
  PHP_CONFIG_EXECUTABLE
  NAMES php-config
  DOC "Path to the php-config development helper command-line tool"
)

################################################################################
# The PHP component.
################################################################################

# Try pkg-config.
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_PHP QUIET php)
endif()

# Get PHP include directories.
if(PHP_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${PHP_CONFIG_EXECUTABLE}" --includes
    OUTPUT_VARIABLE PHP_INCLUDE_DIRS
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if(PHP_INCLUDE_DIRS)
    separate_arguments(PHP_INCLUDE_DIRS NATIVE_COMMAND "${PHP_INCLUDE_DIRS}")
    list(TRANSFORM PHP_INCLUDE_DIRS REPLACE "^-I" "")
  endif()
endif()

find_path(
  PHP_INCLUDE_DIR
  NAMES main/php_config.h
  HINTS
    ${PC_PHP_INCLUDE_DIRS}
    ${PHP_INCLUDE_DIRS}
  DOC "Directory containing PHP main binding headers"
)

if(NOT PHP_INCLUDE_DIR)
  string(APPEND _reason "main/php_config.h not found. ")
else()
  set(PHP_php_FOUND TRUE)
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

# Get PHP_EXTENSION_DIR.
if(PHP_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND "${PHP_CONFIG_EXECUTABLE}" --extension-dir
    OUTPUT_VARIABLE PHP_EXTENSION_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
endif()
if(NOT PHP_EXTENSION_DIR AND PKG_CONFIG_FOUND)
  pkg_get_variable(PHP_EXTENSION_DIR php extensiondir)
endif()

################################################################################
# PHP Embed component.
################################################################################

if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_PHP_EMBED QUIET php-embed)
endif()

find_library(
  PHP_EMBED_LIBRARY
  NAMES php
  HINTS ${PC_PHP_EMBED_LIBRARY_DIRS}
  DOC "The path to the libphp embed library"
)

find_path(
  PHP_EMBED_INCLUDE_DIR
  NAMES sapi/embed/php_embed.h
  HINTS
    ${PC_PHP_EMBED_INCLUDE_DIRS}
    ${PHP_INCLUDE_DIRS}
  DOC "Directory containing PHP Embed SAPI header(s)"
)

if(PHP_EMBED_LIBRARY AND PHP_EMBED_INCLUDE_DIR)
  set(PHP_embed_FOUND TRUE)
elseif("embed" IN_LIST PHP_FIND_COMPONENTS)
  if(NOT PHP_EMBED_INCLUDE_DIR)
    string(APPEND _reason "sapi/embed/php_embed.h not found. ")
  endif()

  if(NOT PHP_EMBED_LIBRARY)
    string(APPEND _reason "PHP library (libphp) not found. ")
  endif()
endif()

################################################################################
# Get PHP version and API numbers.
################################################################################

# Get PHP version.
block(PROPAGATE PHP_VERSION)
  if(${PHP_INCLUDE_DIR}/main/php_version.h)
    set(regex "^[ \t]*#[ \t]*define[ \t]+PHP_VERSION[ \t]+\"([^\"]+)\"[ \t]*$")
    file(
      STRINGS
      ${PHP_INCLUDE_DIR}/main/php_version.h
      result
      REGEX "${regex}"
      LIMIT_COUNT 1
    )
    if(result MATCHES "${regex}")
      set(PHP_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()

  if(
    NOT PHP_VERSION
    AND PC_PHP_VERSION
    AND PHP_INCLUDE_DIR IN_LIST PC_PHP_INCLUDE_DIRS
  )
    set(PHP_VERSION ${PC_PHP_VERSION})
  endif()
endblock()

# Get PHP API version number.
file(READ ${PHP_INCLUDE_DIR}/main/php.h _)
string(REGEX MATCH "#[ \t]*define[ \t]+PHP_API_VERSION[ \t]+([0-9]+)" _ "${_}")
set(PHP_API_VERSION "${CMAKE_MATCH_1}")

# Get PHP extensions API version number.
file(READ ${PHP_INCLUDE_DIR}/Zend/zend_modules.h _)
string(REGEX MATCH "#[ \t]*define[ \t]+ZEND_MODULE_API_NO[ \t]+([0-9]+)" _ "${_}")
set(PHP_ZEND_MODULE_API "${CMAKE_MATCH_1}")

# Get Zend extensions API version number.
file(READ ${PHP_INCLUDE_DIR}/Zend/zend_extensions.h _)
string(REGEX MATCH "#[ \t]*define[ \t]+ZEND_EXTENSION_API_NO[ \t]+([0-9]+)" _ "${_}")
set(PHP_ZEND_EXTENSION_API "${CMAKE_MATCH_1}")

mark_as_advanced(
  PHP_CONFIG_EXECUTABLE
  PHP_INCLUDE_DIR
  PHP_EMBED_LIBRARY
  PHP_EMBED_INCLUDE_DIR
)

################################################################################
# Handle package standard arguments.
################################################################################

find_package_handle_standard_args(
  PHP
  REQUIRED_VARS
    PHP_INCLUDE_DIR
    PHP_API_VERSION
    PHP_ZEND_MODULE_API
    PHP_ZEND_EXTENSION_API
  VERSION_VAR PHP_VERSION
  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT PHP_FOUND)
  return()
endif()

################################################################################
# Post-find configuration.
################################################################################

set(PHP_LIBRARIES ${PHP_EMBED_LIBRARY})

if(NOT TARGET PHP::PHP)
  add_library(PHP::PHP INTERFACE IMPORTED)

  set_target_properties(
    PHP::PHP
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${PHP_INCLUDE_DIRS}"
  )
endif()

if(PHP_embed_FOUND AND NOT TARGET PHP::EMBED)
  add_library(PHP::EMBED UNKNOWN IMPORTED)

  set_target_properties(
    PHP::EMBED
    PROPERTIES
      IMPORTED_LOCATION "${PHP_EMBED_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${PHP_EMBED_INCLUDE_DIR}"
  )
endif()
