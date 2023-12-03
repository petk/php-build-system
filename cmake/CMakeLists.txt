cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# Configure CMake behavior.
include(cmake/CMakeDefaults.cmake)

message("
+--------------------------------------------------------------------+
| Running system checks                                              |
+--------------------------------------------------------------------+
")

# Set the PHP_VERSION_* variables from configure.ac.
include(cmake/Version.cmake)

project(
  PHP
  VERSION "${PHP_VERSION}"
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C CXX ASM
)

# TODO: Adjust setting ccache.
find_program(CCACHE_EXECUTABLE ccache)
if(CCACHE_EXECUTABLE AND NOT CCACHE_DISABLE AND NOT "$ENV{CCACHE_DISABLE}")
  message(STATUS "Using ccache")
  set(CMAKE_C_COMPILER_LAUNCHER ccache)
  set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

# Create a project wide INTERFACE library with project configuration.
add_library(php_configuration INTERFACE)
add_library(PHP::configuration ALIAS php_configuration)

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
| Configuring PEAR                                                   |
+--------------------------------------------------------------------+
")
add_subdirectory(pear)

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
add_subdirectory(main)
add_subdirectory(TSRM)
add_subdirectory(scripts)

# Execute all deferred calls.
cmake_language(DEFER GET_CALL_IDS php_call_ids)
foreach(id ${php_call_ids})
  cmake_language(DEFER GET_CALL ${id} php_call)
  cmake_language(CALL ${php_call})
  cmake_language(DEFER CANCEL_CALL ${id})
endforeach()

enable_testing()

include(ProcessorCount)
processorcount(N)

if(NOT N EQUAL 0)
  set(_run_tests_jobs -j${N})
endif()

# TODO: Append options for running test script.
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
        -d zend_extension=opcache
        ${_run_tests_jobs}
        -q
)

message("
+--------------------------------------------------------------------+
| Summary                                                            |
+--------------------------------------------------------------------+
")
include(FeatureSummary)
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

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
