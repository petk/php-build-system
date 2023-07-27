cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

# Set the module path to include the directory containing custom modules.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")

# Define some CMake defaults.
include(DefineCMakeDefaults)

project(
  PHP
  VERSION 8.3.0
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C ASM
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

# Set PHP version variables.
set(PHP_VERSION_LABEL "-dev" CACHE STRING "Extra PHP version label suffix, e.g. '-dev', 'rc1', '-acme'")
string(CONCAT PHP_VERSION "${PHP_VERSION_MAJOR}" "." "${PHP_VERSION_MINOR}" "." "${PHP_VERSION_PATCH}" "${PHP_VERSION_LABEL}")
math(EXPR PHP_VERSION_ID "${PHP_VERSION_MAJOR} * 10000 + ${PHP_VERSION_MINOR} * 100 + ${PHP_VERSION_PATCH}")

# Create a list of extensions.
include(PHPExtension)

include(ConfigureChecks)

# Parser and lexer generators.
find_package(BISON 3.0.0 REQUIRED)
find_package(re2c 1.0.3 REQUIRED)

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

option(DEBUG "Whether to include debugging symbols" OFF)

if(DEBUG)
  set(ZEND_DEBUG 1)
else()
  set(ZEND_DEBUG 0)
endif()

option(SHORT_TAGS "Whether to enable short tags by default" ON)

if(SHORT_TAGS)
  set(DEFAULT_SHORT_OPEN_TAG "1" CACHE STRING "Whether to enable the short-form <? start tag by default")
else()
  set(DEFAULT_SHORT_OPEN_TAG "0" CACHE STRING "Whether to enable the short-form <? start tag by default")
endif()

option(ZTS "Enable thread safety" OFF)

if(ZTS)
  set(ZTS 1)
else()
  set(ZTS 0)
endif()

option(RTLD_NOW "Whether to dlopen extensions with RTLD_NOW instead of RTLD_LAZY" OFF)

if(RTLD_NOW)
  set(PHP_USE_RTLD_NOW 1 CACHE STRING "Use dlopen with RTLD_NOW instead of RTLD_LAZY")
endif()

set(PHP_OS "${CMAKE_SYSTEM_NAME}" CACHE STRING "uname output")

if(CMAKE_UNAME)
  execute_process(COMMAND ${CMAKE_UNAME} -a
          OUTPUT_VARIABLE PHP_UNAME
          OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_QUIET)
endif()

## Add PHP extensions.
include(IncludeExtensions)

# Add SAPI modules.
add_subdirectory(sapi/apache2handler)
add_subdirectory(sapi/cgi)
add_subdirectory(sapi/cli)
add_subdirectory(sapi/embed)
add_subdirectory(sapi/fpm)
add_subdirectory(sapi/fuzzer)
add_subdirectory(sapi/litespeed)
add_subdirectory(sapi/phpdbg)

# Add PHP engine.
add_subdirectory(main)
add_subdirectory(TSRM)
add_subdirectory(Zend)

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
