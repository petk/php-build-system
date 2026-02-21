#[=============================================================================[
# FindPHP

Finds PHP, the general-purpose scripting language:

```cmake
find_package(PHP [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
find_package() command:

```cmake
find_package(PHP [COMPONENTS <components>...])
```

Supported components include:

* `Interpreter` - Finds the PHP command-line interpreter executable.

## Imported targets

This module provides the following imported targets when `CMAKE_ROLE` is
`PROJECT`:

* `PHP::Interpreter` - Imported executable target encapsulating the PHP
  command-line interpreter usage requirements.

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

* `PHP_FORCE_AS_FOUND` - If set to a boolean true, it disables finding PHP and
  considers it as found. This module will then not provide further results or
  outputs. This is used when building PHP extensions as bundled inside the
  php-src repository, where the host PHP installation isn't required for a
  successful build as a whole.

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
  message(STATUS "Imported target: PHP_HOST::Interpreter")
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
  if(PHP_FORCE_AS_FOUND)
    set(PHP_FOUND TRUE)
    set(PHP${_php_prefix}_FOUND TRUE)
    return()
  endif()

  set(reason "")

  # Set default components.
  if(NOT PHP_FIND_COMPONENTS)
    set(PHP_FIND_COMPONENTS Interpreter)
  endif()

  set(required_vars "")

  ##############################################################################
  # Find the PHP executable.
  ##############################################################################

  if("Interpreter" IN_LIST PHP_FIND_COMPONENTS)
    list(APPEND required_vars PHP${_php_prefix}_EXECUTABLE)

    find_program(
      PHP${_php_prefix}_EXECUTABLE
      NAMES php
      DOC "Path to the PHP executable"
    )
    mark_as_advanced(PHP${_php_prefix}_EXECUTABLE)

    if(IS_EXECUTABLE "${PHP${_php_prefix}_EXECUTABLE}")
      set(PHP_Interpreter_FOUND TRUE)
    else()
      set(PHP_Interpreter_FOUND FALSE)
      string(APPEND reason "The php command-line executable not found. ")
    endif()
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
    REQUIRED_VARS ${required_vars}
    VERSION_VAR PHP${_php_prefix}_VERSION
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
    REASON_FAILURE_MESSAGE "${reason}"
  )

  set(PHP${_php_prefix}_FOUND ${PHP_FOUND})

  ##############################################################################
  # Create imported targets.
  ##############################################################################

  get_property(role GLOBAL PROPERTY CMAKE_ROLE)

  if(
    "Interpreter" IN_LIST PHP_FIND_COMPONENTS
    AND PHP${_php_prefix}_FOUND
    AND PHP_Interpreter_FOUND
    AND role STREQUAL "PROJECT"
    AND NOT TARGET PHP${_php_prefix}::Interpreter
  )
    add_executable(PHP${_php_prefix}::Interpreter IMPORTED)
    set_target_properties(
      PHP${_php_prefix}::Interpreter
      PROPERTIES
        IMPORTED_LOCATION "${PHP${_php_prefix}_EXECUTABLE}"
    )
  endif()
endblock()

unset(_php_prefix)
