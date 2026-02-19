#[=============================================================================[
# PHP/Extension

This module provides commands to configure PHP extensions.

Load this module in a PHP extension's project with:

```cmake
include(PHP/Extension)
```

## Commands

### `php_extension()`

Configures PHP extension:

```cmake
php_extension(<php-extension-name>)
```

The arguments are:

* `<php-extension-name>` - lowercase name of the PHP extension being configured.

This command adjusts configuration in the current directory for building PHP
extension and prepares its target for using it with PHP.

## Examples

Configuring PHP extension:

```cmake
# ext/foo/CMakeLists.txt

include(PHP/Extension)
php_extension(foo)
```
#]=============================================================================]

include_guard(GLOBAL)

# Configures the PHP extension. This is implemented as a macro instead of a
# function for the enable_testing() to work.
macro(php_extension)
  include(PHP/Internal/DisableInSourceBuilds)
  include(PHP/Internal/CMakeDefaults)
  include(PHP/Internal/Standard)

  cmake_language(
    EVAL CODE
    "cmake_language(DEFER CALL _php_extension_post_configure \"${ARGV0}\")"
  )

  if(PHP_TESTING)
    enable_testing()

    # Add test to execute run-tests.php for all *.phpt files when extension is
    # built as standalone.
    if(TARGET PHP::Interpreter)
      include(PHP/Internal/Testing)
      php_testing_add("${ARGV0}")
    endif()
  endif()
endmacro()

function(_php_extension_post_configure)
  set(extension ${ARGV0})

  # Link the imported target from the found PHP package which contains usage
  # requirements (include directories and configuration) for the extension.
  target_link_libraries(php_ext_${extension} PRIVATE PHP::Extension)

  if(NOT TARGET PHP::ext::${extension})
    add_library(PHP::ext::${extension} ALIAS php_ext_${extension})
  endif()

  # Set target output filename to "<extension>".
  get_target_property(output php_ext_${extension} OUTPUT_NAME)
  if(NOT output)
    set_property(TARGET php_ext_${extension} PROPERTY OUTPUT_NAME ${extension})
  endif()

  get_target_property(prefix php_ext_${extension} PREFIX)
  if(NOT prefix)
    set_property(TARGET php_ext_${extension} PROPERTY PREFIX "")
  endif()

  get_target_property(type php_ext_${extension} TYPE)

  # Set build-phase location for shared extensions.
  if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    get_target_property(location php_ext_${extension} LIBRARY_OUTPUT_DIRECTORY)
    if(NOT location)
      # Check whether extension is built as standalone or inside php-src.
      if(PHP_BINARY_DIR)
        set(library_output_dir "${PHP_BINARY_DIR}/modules")
      else()
        set(library_output_dir "${CMAKE_CURRENT_BINARY_DIR}/modules")
      endif()

      get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

      if(NOT is_multi_config)
        string(APPEND library_output_dir "/$<CONFIG>")
      endif()

      set_property(
        TARGET php_ext_${extension}
        PROPERTY LIBRARY_OUTPUT_DIRECTORY "${library_output_dir}"
      )
    endif()
  endif()

  ##############################################################################
  # Prepend COMPILE_DL_<EXTENSION> macro to extension's configuration header
  # (config.h) and define it for shared extensions.
  ##############################################################################

  string(TOUPPER "COMPILE_DL_${extension}" macro)

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

  get_target_property(binary_dir php_ext_${extension} BINARY_DIR)
  set(current "")
  if(EXISTS ${binary_dir}/config.h)
    file(READ ${binary_dir}/config.h current)
  endif()

  # Finalize extension's config.h header file.
  if(NOT current MATCHES "(#undef|#define) ${macro}")
    string(STRIP "${template}\n${current}" config)
    file(CONFIGURE OUTPUT ${binary_dir}/config.h CONTENT "${config}\n")
  endif()

  ##############################################################################
  # Specify extension's default installation rules.
  ##############################################################################

  get_target_property(sets php_ext_${extension} INTERFACE_HEADER_SETS)
  set(file_sets "")
  foreach(set IN LISTS sets)
    list(
      APPEND
      file_sets
      FILE_SET
      ${set}
      DESTINATION
      ${PHP_INSTALL_INCLUDEDIR}/ext/${extension}
      COMPONENT php-development
    )
  endforeach()

  # Install files to system destinations when running 'cmake --install'.
  install(
    TARGETS php_ext_${extension}
    ARCHIVE EXCLUDE_FROM_ALL
    RUNTIME
      DESTINATION ${PHP_EXTENSION_DIR}
      COMPONENT php
    LIBRARY
      DESTINATION ${PHP_EXTENSION_DIR}
      COMPONENT php
    ${file_sets}
  )

  ##############################################################################
  # Output configuration summary.
  ##############################################################################

  if(PROJECT_IS_TOP_LEVEL)
    feature_summary(
      WHAT
        ENABLED_FEATURES
        RECOMMENDED_PACKAGES_NOT_FOUND
        REQUIRED_PACKAGES_NOT_FOUND
      DESCRIPTION "PHP extension ${extension} summary:"
      QUIET_ON_EMPTY
      FATAL_ON_MISSING_REQUIRED_PACKAGES
    )
  endif()
endfunction()
