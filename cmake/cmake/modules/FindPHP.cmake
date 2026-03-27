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
* `PHP_THREAD_SAFETY` - Boolean indicating whether the found PHP is built with
  thread safety enabled.
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

cmake_minimum_required(VERSION 4.3...4.4)

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

################################################################################
# Configuration.
################################################################################

set_package_properties(
  PHP
  PROPERTIES
    URL "https://www.php.net"
    DESCRIPTION "Widely-used general-purpose scripting language"
)

if(PHP_ARTIFACTS_PREFIX)
  set(_php_prefix "${PHP_ARTIFACTS_PREFIX}")
else()
  set(_php_prefix "")
endif()

################################################################################
# Internal helpers.
################################################################################

# Determine PHP library directory where build-system files are installed. PHP
# built with Autotools currently doesn't provide any useful option to retrieve
# where the build-related files are installed. For example, gen_stub.php and
# run-tests.php. This reads the hardcoded path from the phpize script for now.
function(_php_find_php_get_lib_dir)
  find_program(
    PHP${_php_prefix}_PHPIZE_EXECUTABLE
    NAMES phpize
    DOC "Path to the PHP script that prepares a PHP extension for compiling"
  )
  mark_as_advanced(PHP${_php_prefix}_PHPIZE_EXECUTABLE)

  if(NOT IS_EXECUTABLE ${PHP${_php_prefix}_PHPIZE_EXECUTABLE})
    return()
  endif()

  file(
    STRINGS
    ${PHP${_php_prefix}_PHPIZE_EXECUTABLE}
    _
    REGEX "^phpdir=\\\"([^\"]+)\\\""
    LIMIT_COUNT 1
  )

  set(PHP${_php_prefix}_INSTALL_LIBDIR "${CMAKE_MATCH_1}")

  string(
    REPLACE
    "`"
    ""
    PHP${_php_prefix}_INSTALL_LIBDIR
    "${PHP${_php_prefix}_INSTALL_LIBDIR}"
  )

  string(
    REGEX REPLACE
    "^[ ]*eval[ ]+echo[ ]+"
    ""
    PHP${_php_prefix}_INSTALL_LIBDIR
    "${PHP${_php_prefix}_INSTALL_LIBDIR}"
  )

  string(
    REGEX REPLACE
    "build$"
    ""
    PHP${_php_prefix}_INSTALL_LIBDIR
    "${PHP${_php_prefix}_INSTALL_LIBDIR}"
  )

  string(
    REGEX REPLACE
    "\\\${?(exec_)?prefix}?"
    "${php_install_prefix}"
    PHP${_php_prefix}_INSTALL_LIBDIR
    "${PHP${_php_prefix}_INSTALL_LIBDIR}"
  )

  return(PROPAGATE PHP${_php_prefix}_INSTALL_LIBDIR)
endfunction()

################################################################################
# Find PHP.
################################################################################

block(
  PROPAGATE
    PHP_FOUND
    PHP${_php_prefix}_API_VERSION
    PHP${_php_prefix}_EXTENSION_DIR
    PHP${_php_prefix}_FOUND
    PHP${_php_prefix}_INSTALL_INCLUDEDIR
    PHP${_php_prefix}_INSTALL_LIBDIR
    PHP${_php_prefix}_THREAD_SAFETY
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
  # Find PHP development-related files.
  ##############################################################################

  if("Development" IN_LIST PHP_FIND_COMPONENTS)
    list(APPEND required_vars PHP${_php_prefix}_INSTALL_INCLUDEDIR)

    find_program(
      PHP${_php_prefix}_CONFIG_EXECUTABLE
      NAMES php-config
      DOC "Path to the php-config command-line helper"
    )
    mark_as_advanced(PHP${_php_prefix}_CONFIG_EXECUTABLE)

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
    endif()

    _php_find_php_get_lib_dir()

    # Determine thread safety of the found PHP package.
    if(IS_EXECUTABLE "${PHP${_php_prefix}_EXECUTABLE}")
      execute_process(
        COMMAND ${PHP${_php_prefix}_EXECUTABLE} -r "var_dump(PHP_ZTS);"
        OUTPUT_VARIABLE output
        RESULT_VARIABLE result
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      set(PHP${_php_prefix}_THREAD_SAFETY FALSE)

      if(result EQUAL 0 AND output MATCHES "^bool\\\((.+)\\\)")
        set(PHP${_php_prefix}_THREAD_SAFETY "${CMAKE_MATCH_1}")
      endif()
    elseif(PHP${_php_prefix}_INSTALL_INCLUDEDIR)
      include(CheckSymbolExists)
      include(CMakePushCheckState)

      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_INCLUDES "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}")
        set(CMAKE_REQUIRED_QUIET TRUE)

        check_symbol_exists(ZTS main/php_config.h PHP${_php_prefix}_HAS_ZTS)

        if(PHP${_php_prefix}_HAS_ZTS)
          set(PHP${_php_prefix}_THREAD_SAFETY TRUE)
        else()
          set(PHP${_php_prefix}_THREAD_SAFETY FALSE)
        endif()
      cmake_pop_check_state()
    endif()
  endif()

  ##############################################################################
  # Get PHP version variables.
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
  elseif(EXISTS "${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main/php_version.h")
    file(
      STRINGS
      ${PHP${_php_prefix}_INSTALL_INCLUDEDIR}/main/php_version.h
      _
      REGEX
      "^[ \t]*#[ \t]*define[ \t]+PHP_VERSION[ \t]+\\\"([^\"]+)\\\"[ \t]*$"
      LIMIT_COUNT 1
    )

    set(PHP${_php_prefix}_VERSION "${CMAKE_MATCH_1}")
  endif()

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
