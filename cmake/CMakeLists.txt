cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# Configure CMake behavior.
include(cmake/CMakeDefaults.cmake)

message("
+--------------------------------------------------------------------+
| Running system checks                                              |
+--------------------------------------------------------------------+
")

message(STATUS "CMake version: ${CMAKE_VERSION}")

# Set the PHP_VERSION_* variables from configure.ac.
include(cmake/Version.cmake)

project(
  PHP
  VERSION ${PHP_VERSION}
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C CXX ASM
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

# Setup Ccache.
include(PHP/Ccache)

# Create a project wide INTERFACE library with project configuration.
add_library(php_configuration INTERFACE)
add_library(PHP::configuration ALIAS php_configuration)
target_include_directories(
  php_configuration INTERFACE ${PHP_BINARY_DIR} ${PHP_SOURCE_DIR}
)

# Configure build types.
include(cmake/BuildTypes.cmake)

# Set platform specific configuration.
include(cmake/Platform.cmake)

# Set PHP configuration options and variables.
include(cmake/Configuration.cmake)

# Check requirements.
include(cmake/Requirements.cmake)

# Run PHP configuration checks.
include(cmake/ConfigureChecks.cmake)

# Check compilation options.
include(cmake/Flags.cmake)

message("
+--------------------------------------------------------------------+
| Configuring SAPI modules                                           |
+--------------------------------------------------------------------+
")
add_subdirectory(sapi/apache2handler)
add_subdirectory(sapi/cgi)
add_subdirectory(sapi/cli)
add_subdirectory(sapi/embed)
add_subdirectory(sapi/fpm)
add_subdirectory(sapi/fuzzer)
add_subdirectory(sapi/litespeed)
add_subdirectory(sapi/phpdbg)

message("
+--------------------------------------------------------------------+
| Configuring PHP extensions                                         |
+--------------------------------------------------------------------+
")
include(PHP/Extensions)
php_extensions_add(ext)

message("
+--------------------------------------------------------------------+
| Configuring Zend engine                                            |
+--------------------------------------------------------------------+
")
add_subdirectory(Zend)

message("
+--------------------------------------------------------------------+
| Configuring PHP                                                    |
+--------------------------------------------------------------------+
")
add_subdirectory(pear)
add_subdirectory(TSRM)
add_subdirectory(win32)
add_subdirectory(main)
add_subdirectory(scripts)

# Execute all deferred calls.
block()
  cmake_language(DEFER GET_CALL_IDS ids)
  foreach(id ${ids})
    cmake_language(DEFER GET_CALL ${id} call)
    list(POP_FRONT call command)
    cmake_language(CALL ${command} ${call})
    cmake_language(DEFER CANCEL_CALL ${id})
  endforeach()
endblock()

enable_testing()

# TODO: Append options for running test script.
block()
  include(ProcessorCount)
  processorcount(N)

  if(NOT N EQUAL 0)
    set(parallel -j${N})
  endif()

  get_cmake_property(extensions PHP_EXTENSIONS)
  foreach(extension ${extensions})
    get_target_property(extension_type php_${extension} TYPE)
    if(extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      get_target_property(is_zend_extension php_${extension} PHP_ZEND_EXTENSION)
      if(is_zend_extension)
        list(APPEND options -d zend_extension=${extension})
      else()
        list(APPEND options -d extension=${extension})
      endif()
    endif()
  endforeach()

  add_test(
    NAME php_test
    COMMAND
      ./sapi/cli/php
        -n
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        run-tests.php
          -n
          -d extension_dir=modules
          ${options}
          ${parallel}
          -q
  )
endblock()

message("
+--------------------------------------------------------------------+
| Summary                                                            |
+--------------------------------------------------------------------+
")
include(FeatureSummary)
feature_summary(
  FATAL_ON_MISSING_REQUIRED_PACKAGES
  WHAT ENABLED_FEATURES REQUIRED_PACKAGES_NOT_FOUND
)

message("
+--------------------------------------------------------------------+
| License:                                                           |
| This software is subject to the PHP License, available in this     |
| distribution in the file LICENSE. By continuing this installation  |
| process, you are bound by the terms of this license agreement.     |
| If you do not agree with the terms of this license, you must abort |
| the installation process at this point.                            |
+--------------------------------------------------------------------+

Thank you for using PHP.
")
