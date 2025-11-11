#[=============================================================================[
# FindPHP

Finds PHP, the general-purpose scripting language:

```cmake
find_package(PHP [<version>] [...])
```

## Result variables

This module defines the following variables:

* `PHP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `PHP_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `PHP_EXECUTABLE` - PHP command-line tool, if available.

## Hints

* `PHP_ARTIFACTS_PREFIX` - A prefix that will be used for all result and cache
  variables.

  To comply with standard find modules, the `PHP_FOUND` result variable is also
  defined, even if prefix has been specified.

## Examples

### Example: Finding PHP

```cmake
# CMakeLists.txt

find_package(PHP)

if(PHP_FOUND)
  message(STATUS "PHP_EXECUTABLE=${PHP_EXECUTABLE}")
  message(STATUS "PHP_VERSION=${PHP_VERSION}")
endif()
```

### Example: Using hint variables

Finding PHP on the host and prefixing the module result/cache variables:

```cmake
set(PHP_ARTIFACTS_PREFIX "_HOST")
find_package(PHP)
unset(PHP_ARTIFACTS_PREFIX)

if(PHP_HOST_FOUND)
  message(STATUS "PHP_HOST_EXECUTABLE=${PHP_HOST_EXECUTABLE}")
  message(STATUS "PHP_HOST_VERSION=${PHP_HOST_VERSION}")
endif()
```
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

##############################################################################
# Configuration.
##############################################################################

set_package_properties(
  PHP
  PROPERTIES
    URL "https://www.php.net"
    DESCRIPTION "PHP: Hypertext Preprocessor"
)

if(PHP_ARTIFACTS_PREFIX)
  set(_php_prefix "${PHP_ARTIFACTS_PREFIX}")
else()
  set(_php_prefix "")
endif()

block(
  PROPAGATE
    PHP_FOUND
    PHP${_php_prefix}_FOUND
    PHP${_php_prefix}_VERSION
)
  set(reason "")

  ##############################################################################
  # Find the PHP executable.
  ##############################################################################

  find_program(
    PHP${_php_prefix}_EXECUTABLE
    NAMES php
    DOC "Path to the PHP executable"
  )
  mark_as_advanced(PHP${_php_prefix}_EXECUTABLE)

  if(NOT PHP${_php_prefix}_EXECUTABLE)
    string(APPEND reason "The php command-line executable not found. ")
  endif()

  ##############################################################################
  # Check version.
  ##############################################################################

  if(IS_EXECUTABLE "${PHP${_php_prefix}_EXECUTABLE}")
    execute_process(
      COMMAND "${PHP${_php_prefix}_EXECUTABLE}" --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
      string(
        APPEND
        reason
        "Command '${PHP${_php_prefix}_EXECUTABLE} --version' failed. "
      )
    elseif(version MATCHES "PHP ([^ ]+) ")
      set(PHP${_php_prefix}_VERSION "${CMAKE_MATCH_1}")
    else()
      string(APPEND reason "Invalid version format. ")
    endif()
  endif()

  ##############################################################################
  # Handle result.
  ##############################################################################

  find_package_handle_standard_args(
    PHP
    REQUIRED_VARS
      PHP${_php_prefix}_EXECUTABLE
    VERSION_VAR PHP${_php_prefix}_VERSION
    HANDLE_VERSION_RANGE
    REASON_FAILURE_MESSAGE "${reason}"
  )

  set(PHP${_php_prefix}_FOUND ${PHP_FOUND})
endblock()

unset(_php_prefix)
