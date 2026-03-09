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
* `PHP_EXTENSION_DIR` - The path where PHP shared extensions are located.
* `PHP_API_VERSION` - The PHP API version.
* `PHP_ZEND_VERSION` - The version of the Zend Engine.
* `PHP_ZEND_MODULE_API_NO` - The API number for PHP extensions.
* `PHP_ZEND_EXTENSION_API_NO` - The API number for Zend extensions.

## Cache variables

The following cache variables may also be set:

* `PHP_EXECUTABLE` - PHP command-line tool, if available.
* `PHP_CONFIG_EXECUTABLE` - PHP config command-line helper script.

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
    PHP${_php_prefix}_API_VERSION
    PHP${_php_prefix}_EXTENSION_DIR
    PHP${_php_prefix}_FOUND
    PHP${_php_prefix}_INSTALL_INCLUDEDIR
    PHP${_php_prefix}_INSTALL_LIBDIR
    PHP${_php_prefix}_VERSION
    PHP${_php_prefix}_ZEND_EXTENSION_API_NO
    PHP${_php_prefix}_ZEND_MODULE_API_NO
    PHP${_php_prefix}_ZEND_VERSION
)
  if(PHP_FORCE_AS_FOUND)
    set(PHP_FOUND TRUE)
    set(PHP${_php_prefix}_FOUND TRUE)
    return()
  endif()

  set(reason "")

  # Set default components.
  if(NOT PHP_FIND_COMPONENTS)
    set(PHP_FIND_COMPONENTS Interpreter Development)
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
  # Find PHP development-related files.
  ##############################################################################

  if("Development" IN_LIST PHP_FIND_COMPONENTS)
    find_program(
      PHP${_php_prefix}_CONFIG_EXECUTABLE
      NAMES php-config
      DOC "Path to the php-config command-line helper"
    )

    if(IS_EXECUTABLE "${PHP${_php_prefix}_CONFIG_EXECUTABLE}")
      execute_process(
        COMMAND "${PHP${_php_prefix}_CONFIG_EXECUTABLE}" --extension-dir
        OUTPUT_VARIABLE PHP${_php_prefix}_EXTENSION_DIR
        RESULT_VARIABLE result
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      if(NOT result EQUAL 0)
        string(
          APPEND
          reason
          "Command '${PHP${_php_prefix}_CONFIG_EXECUTABLE}' failed. "
        )

        unset(PHP${_php_prefix}_EXTENSION_DIR)
      endif()

      execute_process(
        COMMAND "${PHP${_php_prefix}_CONFIG_EXECUTABLE}" --include-dir
        OUTPUT_VARIABLE PHP${_php_prefix}_INSTALL_INCLUDEDIR
        RESULT_VARIABLE result
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      if(NOT result EQUAL 0)
        string(
          APPEND
          reason
          "Command '${PHP${_php_prefix}_CONFIG_EXECUTABLE}' failed. "
        )

        unset(PHP${_php_prefix}_INSTALL_INCLUDEDIR)
        set(PHP_Development_FOUND FALSE)
      else()
        set(PHP_Development_FOUND TRUE)
      endif()

      execute_process(
        COMMAND "${PHP${_php_prefix}_CONFIG_EXECUTABLE}" --prefix
        OUTPUT_VARIABLE php_install_prefix
        RESULT_VARIABLE result
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      if(PHP${_php_prefix}_VERSION VERSION_GREATER_EQUAL 8.4)
        execute_process(
          COMMAND "${PHP${_php_prefix}_CONFIG_EXECUTABLE}" --lib-dir
          OUTPUT_VARIABLE PHP${_php_prefix}_INSTALL_LIBDIR
          RESULT_VARIABLE result
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(NOT result EQUAL 0)
          string(
            APPEND
            reason
            "Command '${PHP${_php_prefix}_CONFIG_EXECUTABLE}' failed. "
          )

          unset(PHP${_php_prefix}_INSTALL_LIBDIR)
        else()
          string(
            REPLACE
            "\${prefix}"
            "${php_install_prefix}"
            PHP${_php_prefix}_INSTALL_LIBDIR
            "${PHP${_php_prefix}_INSTALL_LIBDIR}"
          )
        endif()
      elseif(EXISTS "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main/build-defs.h")
        file(
          STRINGS
          ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main/build-defs.h
          _
          REGEX
          "^[ \t]*#[ \t]*define[ \t]+PHP_LIBDIR[ \t]+\\\"([^\"]+)\\\"[ \t]*$"
          LIMIT_COUNT 1
        )

        set(PHP${_php_prefix}_INSTALL_LIBDIR "${CMAKE_MATCH_1}")
      endif()
    endif()
  endif()

  ##############################################################################
  # Get PHP version variables.
  ##############################################################################

  if(EXISTS "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main/php.h")
    file(
      STRINGS
      ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main/php.h
      _
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+PHP_API_VERSION[ \t]+([0-9]+)[ \t]*$"
      LIMIT_COUNT 1
    )

    set(PHP${_php_prefix}_API_VERSION "${CMAKE_MATCH_1}")
  endif()

  if(EXISTS "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend/zend.h")
    file(
      STRINGS
      ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend/zend.h
      _
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+ZEND_VERSION[ \t]+([0-9]+)[ \t]*$"
      LIMIT_COUNT 1
    )

    set(PHP${_php_prefix}_ZEND_VERSION "${CMAKE_MATCH_1}")
  endif()

  if(EXISTS "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend/zend_modules.h")
    file(
      STRINGS
      ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend/zend_modules.h
      _
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+ZEND_MODULE_API_NO[ \t]+([0-9]+)[ \t]*$"
      LIMIT_COUNT 1
    )

    set(PHP${_php_prefix}_ZEND_MODULE_API_NO "${CMAKE_MATCH_1}")
  endif()

  if(EXISTS "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend/zend_extensions.h")
    file(
      STRINGS
      ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend/zend_extensions.h
      _
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+ZEND_EXTENSION_API_NO[ \t]+([0-9]+)[ \t]*$"
      LIMIT_COUNT 1
    )

    set(PHP${_php_prefix}_ZEND_EXTENSION_API_NO "${CMAKE_MATCH_1}")
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

  if(
    "Development" IN_LIST PHP_FIND_COMPONENTS
    AND PHP${_php_prefix}_FOUND
    AND PHP_Development_FOUND
    AND role STREQUAL "PROJECT"
    AND NOT TARGET PHP${_php_prefix}::Extension
  )
    add_library(PHP${_php_prefix}::Extension INTERFACE IMPORTED GLOBAL)

    target_include_directories(
      PHP${_php_prefix}::Extension
      INTERFACE
        ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}
        ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main
        ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/TSRM
        ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/Zend
    )

    target_compile_definitions(
      PHP${_php_prefix}::Extension
      INTERFACE HAVE_CONFIG_H ZEND_COMPILE_DL_EXT
    )
  endif()
endblock()

unset(_php_prefix)
