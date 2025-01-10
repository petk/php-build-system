#[=============================================================================[
# FindPHP

Find PHP, the general-purpose scripting language, if it is installed on the
system. This module detects the PHP interpreter and related tools or components,
making them available for use in the build configuration.

## Result variables

This module defines the following result variables common to all PHP components:

* `PHP_FOUND` - Whether the PHP and its requested components have been found.
* `PHP_FOUND_VERSION` - The PHP version found on the system.

TODO: Move and refactor these two:
* `PHP_INCLUDE_DIRS` - List of required include directories when developing PHP
  extensions or embedding PHP into application.
* `PHP_LIBRARIES` - List of libraries required to link when developing PHP
  extensions or embedding PHP into application.

## Components

This module provides the following components:

* `Interpreter` - The PHP interpreter, the command-line executable.
* `Development` - Component for building PHP extensions.
* `Embed` - The PHP embed component, a lightweight SAPI to embed PHP into
  application using C bindings.

Components can be specified using the standard CMake syntax:

```cmake
find_package(PHP COMPONENTS <components>...)
```

If the `COMPONENTS` are not specified, module by default searches for the
`Interpreter` and `Development` components:

```cmake
find_package(PHP)
```

### The `Interpreter` component

When this component is found, it defines the following `IMPORTED` targets:

* `PHP::Interpreter` - `IMPORTED` executable target with the `PHP_EXECUTABLE`
  path that can be used in commands and similar.

Cache variables of the `Interpreter` component:

* `PHP_EXECUTABLE` - PHP command-line executable, if available.

Result variables of the `Interpreter` component:

* `PHP_Interpreter_FOUND` - Whether the PHP `Interpreter` component has been
  found.

### The `Development` component

When this component is found, it defines the following `IMPORTED` targets:

* `PHP::Development` - `IMPORTED` `INTERFACE` library with include directories
  and configuration required for developing PHP extensions.

Cache variables of the `Development` component:

* `PHP_CONFIG_EXECUTABLE` - Path to the `php-config` development command-line
  tool.
* `PHP_INCLUDE_DIR` - Directory containing PHP headers.

Result variables of the `Development` component:

* `PHP_Development_FOUND` - Whether the PHP `Development` component has been
  found.
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
* `PHP_INSTALL_INCLUDEDIR` - Relative path to the `CMAKE_PREFIX_INSTALL`
  containing PHP headers.
* `PHP_EXTENSION_DIR` - Path to the directory where shared extensions are
  installed.

### The `Embed` component

When this component is found, it defines the following `IMPORTED` targets:

* `PHP::Embed` - `IMPORTED` library with include directories and PHP Embed SAPI
  library required to embed PHP into application.

Cache variables of the `Embed` component:

* `PHP_CONFIG_EXECUTABLE` - Path to the `php-config` development helper tool.
* `PHP_EMBED_INCLUDE_DIR` - Directory containing PHP headers.
* `PHP_EMBED_LIBRARY` - The path to the PHP Embed library (`libphp`).

Result variables of the `Embed` component:

* `PHP_Embed_FOUND` - Whether the PHP `Embed` component has been found.

## Examples

### Basic usage

```cmake
# CMakeLists.txt

# Find PHP:
find_package(PHP)

# Or find only the PHP Interpreter component:
find_package(PHP COMPONENTS Interpreter)

# The imported targets can be then linked to the target:
target_link_libraries(php_extension PRIVATE PHP::Development)
```

### How to use CMake in PHP extensions?

Here is an example of a PHP extension called `phantom` for demonstration
purposes that uses CMake-based build system.

To create a brand new PHP extension clone the `php-src` Git repository and run
the `ext_skel.php` helper script, which will create the `ext/phantom` extension:

```sh
git clone https://github.com/php/php-src
cd php-src
./ext/ext_skel.php --ext phantom
```

Create a `cmake` and `cmake/modules` directories in the extension's top level
directory and add this `FindPHP.cmake` module to `cmake/modules`.

Create a `CMakeLists.txt` in the extension's top level directory. For example:

```cmake
# CMakeLists.txt

# Set minimum required CMake version.
cmake_minimum_required(VERSION 3.25...3.31)

# Append extension's local CMake modules.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake/modules)

# Automatically include current source or build tree for the current target.
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Put the source or build tree include directories before other includes.
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# Set the extension's project metadata.
project(
  php_ext_phantom
  VERSION 0.1.0
  DESCRIPTION "Describe the extension"
  HOMEPAGE_URL "https://example.org"
  LANGUAGES C
)

# Include CMake module to use cmake_dependent_option().
include(CMakeDependentOption)

# Include CMake module to use add_feature_info() and set_package_properties().
include(FeatureSummary)

# Boolean option that enables (ON) or disables (OFF) the extension.
option(PHP_EXT_PHANTOM "Enable the phantom extension" ON)

# Extension features are visible in the configuration summary output.
add_feature_info(
  "ext/phantom"
  PHP_EXT_PHANTOM
  "Describe the extension features"
)

# Dependent boolean option that builds extension as a shared library. CMake's
# BUILD_SHARED_LIBS variable hides this option and builds extension as shared.
cmake_dependent_option(
  PHP_EXT_PHANTOM_SHARED
  "Build the phantom extension as a shared library"
  OFF
  [[PHP_EXT_PHANTOM AND NOT BUILD_SHARED_LIBS]]
  OFF
)

# If extension is disabled CMake configuration stops here.
if(NOT PHP_EXT_PHANTOM)
  return()
endif()

# Add a target to be built as a SHARED or STATIC library.
if(PHP_EXT_PHANTOM_SHARED)
  add_library(php_ext_phantom SHARED)
else()
  add_library(php_ext_phantom)
endif()

# Add library target sources.
target_sources(
  php_ext_phantom
  PRIVATE
    phantom.c
  # If extension provides header(s) that will be consumed by other sources and
  # should be installed, add header(s) to a file set.
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_phantom.h
)

# Find PHP on the system.
find_package(PHP REQUIRED)

# Link the PHP::Development imported library which provides the PHP include
# directories and configuration for the extension.
target_link_libraries(php_ext_phantom PRIVATE PHP::Development)

# Install files to system destinations with 'cmake --install'.
install(
  TARGETS php_ext_phantom
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
```

#### Dependencies in PHP extensions

When PHP extension depends on other PHP extensions the best and most user
friendly way is to design the code from the beginning in a way that dependent
PHP extensions can be checked during the runtime. For example:

```c
if (zend_hash_str_exists(&module_registry, "openssl", sizeof("openssl")-1)) {
    // PHP extension "openssl" is enabled.
} else {
    // PHP extension "openssl" is not enabled.
}
```

This makes extension more intuitive to enable and use by the end user.

PHP extensions are often times built as shared, where checking C preprocessor
macros from header files may not be enough. A common but inconvenient approach
is to check for dependent PHP extensions at the compile time. For example:

```c
#ifdef HAVE_OPENSSL_EXT
/* The PHP 'openssl' extension is available. */
#endif

#if defined(HAVE_OPENSSL_EXT) && defined(COMPILE_DL_OPENSSL)
/* The PHP 'openssl' extension is available but is built as shared. */
#endif
```

This however, depends on whether the `HAVE_OPENSSL_EXT` is defined in the
`main/php_config.h` header file. It is unreliable and error prone method when
dependent extension is built as shared and not enabled at runtime.

When extension dependency is required, adding a `ZEND_MOD_REQUIRED` entry
ensures that extensions are loaded in correct order.

When extension depends on an external library, another CMake find module needs
to be used to locate that dependency on the system. See existing usages in the
CMake-based build system for more info.

### Embedding PHP into application

To build example application with embedded PHP, create `CMakeLists.txt`:

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.25...3.31)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake/modules)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

project(ApplicationWithEmbeddedPhp C)

add_executable(app app.c)

# Find the PHP Embed component (PHP Embed SAPI) on the system.
find_package(PHP COMPONENTS Embed)

# Link imported library provided by the PHP find module to the application.
target_link_libraries(app PRIVATE PHP::Embed)
```

Create `app.c`:

```c
/* app.c */
#include <sapi/embed/php_embed.h>

int main(int argc, char **argv)
{
    /* Invokes the Zend Engine initialization phase: SAPI (SINIT), modules
     * (MINIT), and request (RINIT). It also opens a 'zend_try' block to catch
     * a zend_bailout().
     */
    PHP_EMBED_START_BLOCK(argc, argv)

    php_printf(
        "Number of functions loaded: %d\n",
        zend_hash_num_elements(EG(function_table))
    );

    /* Close the 'zend_try' block and invoke the shutdown phase: request
     * (RSHUTDOWN), modules (MSHUTDOWN), and SAPI (SSHUTDOWN).
     */
    PHP_EMBED_END_BLOCK()
}
```

Generate build system to a build directory:

```sh
cmake -B build
```

Build application in parallel:

```sh
cmake --build build -j
```

Run application executable:

```sh
./build/app
```
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  PHP
  PROPERTIES
    URL "https://www.php.net"
    DESCRIPTION "General-purpose scripting language"
)

set(_phpRequiredVars "")
set(_reason "")
set(PHP_FOUND_VERSION "")
set(PHP_INCLUDE_DIRS "")
set(PHP_LIBRARIES "")

if(NOT PHP_FIND_COMPONENTS)
  set(PHP_FIND_COMPONENTS "Interpreter" "Development")
  set(PHP_FIND_REQUIRED_Interpreter TRUE)
  set(PHP_FIND_REQUIRED_Development TRUE)
endif()

################################################################################
# The Interpreter component.
################################################################################

if("Interpreter" IN_LIST PHP_FIND_COMPONENTS)
  find_program(
    PHP_EXECUTABLE
    NAMES php
    DOC "The path to the PHP executable"
  )
  mark_as_advanced(PHP_EXECUTABLE)

  if(NOT PHP_EXECUTABLE)
    string(APPEND _reason "The php command-line executable could not be found. ")
  endif()

  # Mark component as found or not and add required find module variables.
  set(PHP_Interpreter_FOUND TRUE)
  foreach(var IN ITEMS PHP_EXECUTABLE)
    list(APPEND _phpRequiredVars ${var})
    if(NOT ${var})
      set(PHP_Interpreter_FOUND FALSE)
    endif()
  endforeach()
endif()

################################################################################
# Common configuration for Development and Embed components.
################################################################################

if(
  "Development" IN_LIST PHP_FIND_COMPONENTS
  OR "Embed" IN_LIST PHP_FIND_COMPONENTS
)
  # Try pkg-config.
  find_package(PkgConfig QUIET)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_PHP QUIET php)
  endif()

  # Find php-config tool.
  find_program(
    PHP_CONFIG_EXECUTABLE
    NAMES php-config
    DOC "The path to the php-config development helper command-line tool"
  )
  mark_as_advanced(PHP_CONFIG_EXECUTABLE)

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
endif()

################################################################################
# The Development component.
################################################################################

if("Development" IN_LIST PHP_FIND_COMPONENTS)
  find_path(
    PHP_INCLUDE_DIR
    NAMES main/php.h
    HINTS
      ${PC_PHP_INCLUDE_DIRS}
      ${PHP_INCLUDE_DIRS}
    DOC "Directory containing PHP headers"
  )
  mark_as_advanced(PHP_INCLUDE_DIR)

  if(NOT PHP_INCLUDE_DIR)
    string(APPEND _reason "The <main/php.h> header file not found. ")
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

  # Get PHP API version number.
  block(PROPAGATE PHP_API_VERSION)
    if(EXISTS ${PHP_INCLUDE_DIR}/main/php.h)
      set(regex "#[ \t]*define[ \t]+PHP_API_VERSION[ \t]+([0-9]+)")
      file(STRINGS ${PHP_INCLUDE_DIR}/main/php.h _ REGEX "${regex}")

      if(CMAKE_VERSION VERSION_LESS 3.29)
        string(REGEX MATCH "${regex}" _ "${_}")
      endif()

      set(PHP_API_VERSION "${CMAKE_MATCH_1}")
    endif()
  endblock()

  # Get PHP extensions API version number.
  block(PROPAGATE PHP_ZEND_MODULE_API)
    if(EXISTS ${PHP_INCLUDE_DIR}/Zend/zend_modules.h)
      set(regex "#[ \t]*define[ \t]+ZEND_MODULE_API_NO[ \t]+([0-9]+)")
      file(STRINGS ${PHP_INCLUDE_DIR}/Zend/zend_modules.h _ REGEX "${regex}")

      if(CMAKE_VERSION VERSION_LESS 3.29)
        string(REGEX MATCH "${regex}" _ "${_}")
      endif()

      set(PHP_ZEND_MODULE_API "${CMAKE_MATCH_1}")
    endif()
  endblock()

  # Get Zend extensions API version number.
  block(PROPAGATE PHP_ZEND_EXTENSION_API)
    if(EXISTS ${PHP_INCLUDE_DIR}/Zend/zend_extensions.h)
      set(regex "#[ \t]*define[ \t]+ZEND_EXTENSION_API_NO[ \t]+([0-9]+)")
      file(STRINGS ${PHP_INCLUDE_DIR}/Zend/zend_extensions.h _ REGEX "${regex}")

      if(CMAKE_VERSION VERSION_LESS 3.29)
        string(REGEX MATCH "${regex}" _ "${_}")
      endif()

      set(PHP_ZEND_EXTENSION_API "${CMAKE_MATCH_1}")
    endif()
  endblock()

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
      PC_PHP_PREFIX
      BASE_DIRECTORY "${PHP_INSTALL_PREFIX}"
      OUTPUT_VARIABLE PHP_INSTALL_INCLUDEDIR
    )
  endif()

  # Mark component as found or not found and add required find module variables.
  set(PHP_Development_FOUND TRUE)
  foreach(
    var IN ITEMS
      PHP_API_VERSION
      PHP_EXTENSION_DIR
      PHP_INCLUDE_DIR
      PHP_ZEND_EXTENSION_API
      PHP_ZEND_MODULE_API
  )
    list(APPEND _phpRequiredVars ${var})
    if(NOT ${var})
      set(PHP_Development_FOUND FALSE)
    endif()
  endforeach()
endif()

################################################################################
# The Embed component.
################################################################################

if("Embed" IN_LIST PHP_FIND_COMPONENTS)
  # Try pkg-config.
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_PHP_EMBED QUIET php-embed)
  endif()

  find_path(
    PHP_EMBED_INCLUDE_DIR
    NAMES sapi/embed/php_embed.h
    HINTS
      ${PC_PHP_INCLUDE_DIRS}
      ${PC_PHP_EMBED_INCLUDE_DIRS}
      ${PHP_INCLUDE_DIRS}
    DOC "Directory containing PHP headers"
  )
  mark_as_advanced(PHP_EMBED_INCLUDE_DIR)
  if(NOT PHP_EMBED_INCLUDE_DIR)
    string(APPEND _reason "The <sapi/embed/php_embed.h> header file not found. ")
  endif()

  find_library(
    PHP_EMBED_LIBRARY
    NAMES php
    HINTS ${PC_PHP_EMBED_LIBRARY_DIRS}
    DOC "The path to the libphp embed library"
  )
  mark_as_advanced(PHP_EMBED_LIBRARY)
  if(NOT PHP_EMBED_LIBRARY)
    string(APPEND _reason "PHP library (libphp) not found. ")
  else()
    list(APPEND PHP_LIBRARIES ${PHP_EMBED_LIBRARY})
  endif()

  # Mark component as found or not and add required find module variables.
  set(PHP_Embed_FOUND TRUE)
  foreach(var IN ITEMS PHP_EMBED_INCLUDE_DIR PHP_EMBED_LIBRARY)
    list(APPEND _phpRequiredVars ${var})
    if(NOT ${var})
      set(PHP_Embed_FOUND FALSE)
    endif()
  endforeach()
endif()

################################################################################
# Get PHP version.
################################################################################

block(PROPAGATE PHP_FOUND_VERSION _reason)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
    set(test IS_EXECUTABLE)
  else()
    set(test EXISTS)
  endif()

  if(NOT PHP_FOUND_VERSION AND PHP_EXECUTABLE)
    if(${test} ${PHP_EXECUTABLE})
      execute_process(
        COMMAND ${PHP_EXECUTABLE} --version
        OUTPUT_VARIABLE version
        RESULT_VARIABLE result
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
      )

      if(NOT result EQUAL 0)
        string(APPEND _reason "Command '${PHP_EXECUTABLE} --version' failed. ")
      elseif(version MATCHES "PHP ([0-9]+[0-9.]+[^ ]+) \\(cli\\)")
        set(PHP_FOUND_VERSION "${CMAKE_MATCH_1}")
      else()
        string(APPEND _reason "Invalid version format. ")
      endif()
    endif()
  endif()

  if(NOT PHP_FOUND_VERSION AND PHP_CONFIG_EXECUTABLE)
    if(${test} ${PHP_CONFIG_EXECUTABLE})
      execute_process(
        COMMAND ${PHP_CONFIG_EXECUTABLE} --versiona
        OUTPUT_VARIABLE version
        RESULT_VARIABLE result
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
      )

      if(NOT result EQUAL 0)
        string(
          APPEND
          _reason
          "Command '${PHP_CONFIG_EXECUTABLE} --version' failed. "
        )
      elseif(version MATCHES "([0-9]+[0-9.]+[^ \n]+)")
        set(PHP_FOUND_VERSION "${CMAKE_MATCH_1}")
      else()
        string(APPEND _reason "Invalid version format. ")
      endif()
    endif()
  endif()

  set(includeDir "")
  if(NOT PHP_FOUND_VERSION AND PHP_INCLUDE_DIR)
    set(includeDir ${PHP_INCLUDE_DIR})
  elseif(NOT PHP_FOUND_VERSION AND PHP_EMBED_INCLUDE_DIR)
    set(includeDir ${PHP_EMBED_INCLUDE_DIR})
  endif()

  if(
    NOT PHP_FOUND_VERSION
    AND includeDir
    AND EXISTS ${includeDir}/main/php_version.h
  )
    set(regex "^[ \t]*#[ \t]*define[ \t]+PHP_VERSION[ \t]+\"([^\"]+)\"")
    file(
      STRINGS
      ${includeDir}/main/php_version.h
      result
      REGEX "${regex}"
      LIMIT_COUNT 1
    )
    if(CMAKE_VERSION VERSION_LESS 3.29)
      string(REGEX MATCH "${regex}" _ "${result}")
    endif()
    set(PHP_FOUND_VERSION "${CMAKE_MATCH_1}")
  endif()

  if(
    NOT PHP_FOUND_VERSION
    AND PC_PHP_VERSION
    AND PHP_INCLUDE_DIR IN_LIST PC_PHP_INCLUDE_DIRS
  )
    set(PHP_FOUND_VERSION ${PC_PHP_VERSION})
  elseif(
    NOT PHP_FOUND_VERSION
    AND PC_PHP_EMBED_VERSION
    AND PHP_EMBED_INCLUDE_DIR IN_LIST PC_PHP_EMBED_INCLUDE_DIRS
  )
    set(PHP_FOUND_VERSION ${PC_PHP_EMBED_VERSION})
  endif()
endblock()

if(PHP_FIND_VERSION AND NOT PHP_FOUND_VERSION)
  string(APPEND _reason "The PHP version could not be determined. ")
endif()

################################################################################
# Handle package standard arguments.
################################################################################

# Move the most informative variable to the beginning of the list. It is part of
# the result message by find_package_handle_standard_args().
if("PHP_EXECUTABLE" IN_LIST _phpRequiredVars)
  list(PREPEND _phpRequiredVars "PHP_EXECUTABLE")
elseif("PHP_INCLUDE_DIR" IN_LIST _phpRequiredVars)
  list(PREPEND _phpRequiredVars "PHP_INCLUDE_DIR")
elseif("PHP_EMBED_LIBRARY" IN_LIST _phpRequiredVars)
  list(PREPEND _phpRequiredVars "PHP_EMBED_LIBRARY")
endif()
list(REMOVE_DUPLICATES _phpRequiredVars)

find_package_handle_standard_args(
  PHP
  REQUIRED_VARS ${_phpRequiredVars}
  VERSION_VAR PHP_FOUND_VERSION
  HANDLE_VERSION_RANGE
  HANDLE_COMPONENTS
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_phpRequiredVars)
unset(_reason)

################################################################################
# Configuration when PHP is found.
################################################################################

if(NOT PHP_FOUND)
  return()
endif()

################################################################################
# Interpreter component configuration.
################################################################################

if("Interpreter" IN_LIST PHP_FIND_COMPONENTS AND NOT TARGET PHP::Interpreter)
  add_executable(PHP::Interpreter IMPORTED)
  set_target_properties(
    PHP::Interpreter
    PROPERTIES
      IMPORTED_LOCATION "${PHP_EXECUTABLE}"
  )
endif()

################################################################################
# Development component configuration.
################################################################################

if("Development" IN_LIST PHP_FIND_COMPONENTS)
  if(NOT TARGET PHP::Development)
    add_library(PHP::Development INTERFACE IMPORTED)

    set_target_properties(
      PHP::Development
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${PHP_INCLUDE_DIRS}"
    )

    # Compile definitions for PHP extensions:
    target_compile_definitions(
      PHP::Development
      INTERFACE
        $<$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>:ZEND_COMPILE_DL_EXT>
        HAVE_CONFIG_H
    )
  endif()

  cmake_language(DEFER CALL _php_extension_deferred_configuration)
  function(_php_extension_deferred_configuration)
    if(PROJECT_NAME MATCHES "^php_ext_(.+)$")
      set(extension "${CMAKE_MATCH_1}")
    else()
      return()
    endif()

    if(NOT TARGET php_ext_${extension})
      return()
    endif()

    # Set target library filename prefix to empty "" instead of default "lib".
    set_property(TARGET php_ext_${extension} PROPERTY PREFIX "")

    set_target_properties(
      php_ext_${extension}
      PROPERTIES
        POSITION_INDEPENDENT_CODE ON
    )

    # Set target output filename to "<extension>".
    get_target_property(output php_ext_${extension} OUTPUT_NAME)
    if(NOT output)
      set_property(TARGET php_ext_${extension} PROPERTY OUTPUT_NAME ${extension})
    endif()

    # Configure shared extension.
    get_target_property(type php_ext_${extension} TYPE)
    if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      # Set build-phase location for shared extensions.
      get_target_property(location php_ext_${extension} LIBRARY_OUTPUT_DIRECTORY)
      if(NOT location)
        set_property(
          TARGET php_ext_${extension}
          PROPERTY LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/modules"
        )
      endif()
    endif()

    _php_extension_configure_header(${extension})
  endfunction()

  function(_php_extension_configure_header extension)
    string(TOUPPER "COMPILE_DL_${extension}" macro)

    get_target_property(type php_ext_${extension} TYPE)
    if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      set(${macro} TRUE)
    else()
      set(${macro} FALSE)
    endif()

    # Prepare config.h template.
    string(
      JOIN
      ""
      template
      "/* Define to 1 if the PHP extension '@extension@' is built as a dynamic "
      "module. */\n"
      "#cmakedefine ${macro} 1\n"
    )

    get_target_property(binaryDir php_ext_${extension} BINARY_DIR)
    set(current "")
    if(EXISTS ${binaryDir}/config.h)
      file(READ ${binaryDir}/config.h current)
    endif()

    string(STRIP "${template}\n${current}" config)

    # Finalize extension's config.h header file.
    file(CONFIGURE OUTPUT ${binaryDir}/config.h CONTENT "${config}\n")
  endfunction()
endif()

################################################################################
# Embed component configuration.
################################################################################

if("Embed" IN_LIST PHP_FIND_COMPONENTS AND NOT TARGET PHP::Embed)
  if(IS_ABSOLUTE "${PHP_EMBED_LIBRARY}")
    add_library(PHP::Embed UNKNOWN IMPORTED)
    set_target_properties(
      PHP::Embed
      PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES C
        IMPORTED_LOCATION "${PHP_EMBED_LIBRARY}"
    )
  else()
    add_library(PHP::Embed INTERFACE IMPORTED)
    set_target_properties(
      PHP::Embed
      PROPERTIES
        IMPORTED_LIBNAME "${PHP_EMBED_LIBRARY}"
    )
  endif()

  set_target_properties(
    PHP::Embed
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${PHP_INCLUDE_DIRS}"
  )
endif()
