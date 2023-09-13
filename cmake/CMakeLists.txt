cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# Set some CMake defaults.
include(cmake/CMakeDefaults.cmake)

message("
+--------------------------------------------------------------------+
| Running system checks                                              |
+--------------------------------------------------------------------+
")

include(PHPVersion)

message(STATUS "PHP version: ${PHP_VERSION}")

project(
  PHP
  VERSION "${PHP_VERSION_MAJOR}.${PHP_VERSION_MINOR}.${PHP_VERSION_PATCH}"
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C ASM CXX
)

# Set the project version to include additional optional version label.
string(CONCAT PHP_VERSION "${PHP_VERSION_MAJOR}" "." "${PHP_VERSION_MINOR}" "." "${PHP_VERSION_PATCH}" "${PHP_VERSION_LABEL}")

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:_GNU_SOURCE>")

set(PHP_OS "${CMAKE_SYSTEM_NAME}" CACHE INTERNAL "uname output")

# Define GNU standard installation directories.
include(GNUInstallDirs)

# Lexer and parser generators.
include(PHPLexerParser)

# Define PHP configuration options.
include(PHPConfiguration)

# Configuration checks.
include(ConfigureChecks)

# Find sendmail binary.
find_package(SENDMAIL)

# TODO: Check if this can be fixed better.
include_directories(${CMAKE_SOURCE_DIR})
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/main")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/TSRM")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/Zend")

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
| Configuring extensions                                             |
+--------------------------------------------------------------------+
")
include(PHPExtension)
include(PHPIncludeExtensions)

message("
+--------------------------------------------------------------------+
| Configuring Zend                                                   |
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

message("
+--------------------------------------------------------------------+
| Generating files                                                   |
+--------------------------------------------------------------------+
")

# Create main/internal_functions* files.
include(PHPCreateInternalFunctions)

message(STATUS "Creating main/php_version.h")
configure_file(main/php_version.h.in main/php_version.h @ONLY)

# Create main/build-defs.h file.
include(PHPCreateBuildDefinitions)

message(STATUS "Creating main/php_config.h")
configure_file(main/php_config.h.in main/php_config.h @ONLY)

enable_testing()

include(ProcessorCount)
processorcount(N)

if(NOT N EQUAL 0)
  set(_run_tests_jobs -j${N})
endif()

add_test(
  NAME php_test
  COMMAND ./sapi/cli/php run-tests.php ${_run_tests_jobs} -q
)

# Man documentation.
configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/man1/php-config.1.in
  ${CMAKE_BINARY_DIR}/scripts/man1/php-config.1
  @ONLY
)

configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/man1/phpize.1.in
  ${CMAKE_BINARY_DIR}/scripts/man1/phpize.1
  @ONLY
)

# The php-config script.
configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/php-config.in
  ${CMAKE_BINARY_DIR}/scripts/php-config
  @ONLY
)

install(
  FILES
    ${CMAKE_BINARY_DIR}/scripts/man1/php-config.1
    ${CMAKE_BINARY_DIR}/scripts/man1/phpize.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

install(
  FILES
    ${CMAKE_BINARY_DIR}/scripts/php-config
  DESTINATION ${CMAKE_INSTALL_BINDIR}
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
