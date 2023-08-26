cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# Set some CMake defaults.
include(cmake/CMakeDefaults.cmake)

message("
+--------------------------------------------------------------------+
| Running system checks                                              |
+--------------------------------------------------------------------+
")

project(
  PHP
  VERSION 8.3.0
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C ASM CXX
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

# Set PHP version variables.
set(PHP_VERSION_LABEL "-dev" CACHE STRING "Extra PHP version label suffix, e.g. '-dev', 'rc1', '-acme'")
string(CONCAT PHP_VERSION "${PHP_VERSION_MAJOR}" "." "${PHP_VERSION_MINOR}" "." "${PHP_VERSION_PATCH}" "${PHP_VERSION_LABEL}")
math(EXPR PHP_VERSION_ID "${PHP_VERSION_MAJOR} * 10000 + ${PHP_VERSION_MINOR} * 100 + ${PHP_VERSION_PATCH}")

add_compile_definitions("$<$<COMPILE_LANGUAGE:C>:_GNU_SOURCE>")

set(PHP_OS "${CMAKE_SYSTEM_NAME}" CACHE INTERNAL "uname output")

# Define PHP configuration options.
include(PHPConfiguration)

# Configuration checks.
include(ConfigureChecks)

# Find sendmail binary.
find_package(SENDMAIL)

# Parser and lexer generators.
find_package(BISON 3.0.0 REQUIRED)
find_package(RE2C 1.0.3 REQUIRED)

include_directories(${CMAKE_SOURCE_DIR})
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/main")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/TSRM")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/Zend")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/date")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/date/lib")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/hash")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/hash/murmur")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/hash/xxhash")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/json")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/pcre")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/pcre/pcre2lib")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/random")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/reflection")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/spl")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/ext/standard")

## Add PHP extensions.
message("
+--------------------------------------------------------------------+
| Configuring extensions                                             |
+--------------------------------------------------------------------+
")
include(PHPExtension)
include(IncludeExtensions)

# Add SAPI modules.
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

# Add PHP engine.
message("
+--------------------------------------------------------------------+
| Configuring PHP                                                    |
+--------------------------------------------------------------------+
")
add_subdirectory(main)
add_subdirectory(TSRM)

message("
+--------------------------------------------------------------------+
| Configuring Zend                                                   |
+--------------------------------------------------------------------+
")
add_subdirectory(Zend)

message("
+--------------------------------------------------------------------+
| Generating files                                                   |
+--------------------------------------------------------------------+
")
# Create main/internal_functions* files.
include(CreateInternalFunctions)

message(STATUS "Creating main/php_version.h")
configure_file(main/php_version.h.in main/php_version.h @ONLY)

include(CreateBuildDefinitions)
create_build_definitions()

message(STATUS "Creating main/php_config.h")
configure_file(main/php_config.h.in main/php_config.h @ONLY)

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
