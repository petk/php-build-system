cmake_minimum_required(VERSION 4.2...4.3)

message(STATUS "Initializing PHP build system")
message(STATUS "=============================")

# Configure CMake behavior.
include(cmake/CMakeDefaults.cmake)

# Set the PHP_VERSION_* variables from configure.ac.
include(cmake/Version.cmake)

project(
  PHP
  VERSION ${PHP_VERSION}
  #SPDX_LICENSE "PHP-3.01"
  DESCRIPTION "Widely-used general-purpose scripting language"
  HOMEPAGE_URL "https://www.php.net"
  LANGUAGES C
)

################################################################################
# Configure languages.
################################################################################

# Optionally enable C++ language for PHP extensions.
include(CheckLanguage)
check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)
endif()

# Enable Assembly language dialect.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  if(CMAKE_C_COMPILER_ARCHITECTURE_ID MATCHES "(ARM|arm|aarch64)")
    enable_language(ASM_MARMASM)
  else()
    enable_language(ASM_MASM)
  endif()
else()
  enable_language(ASM)
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

################################################################################
# Create interface targets providing usage requirements.
################################################################################

# Usage requirements for all PHP-related targets in the build.
add_library(php_config INTERFACE)
add_library(PHP::config ALIAS php_config)
target_include_directories(
  php_config
  INTERFACE
    ${PHP_BINARY_DIR}
    ${PHP_SOURCE_DIR}
)

# Interface library that ties objects and configuration together for PHP SAPIs.
add_library(php_sapi INTERFACE)
add_library(PHP::sapi ALIAS php_sapi)
target_link_libraries(php_sapi INTERFACE PHP::config)

################################################################################
# Configure project.
################################################################################

define_property(
  TARGET
  PROPERTY PHP_CLI
  BRIEF_DOCS "Whether the PHP SAPI or extension is CLI-based"
)

define_property(
  TARGET
  PROPERTY PHP_SAPI_FASTCGI
  BRIEF_DOCS "Whether the PHP SAPI is FastCGI-based"
)

# Check whether IPO/LTO can be enabled.
include(PHP/Optimization)

# Enable position-independent code (PIC) for all targets and
# position-independent executables (PIE) for executable targets.
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
include(CheckPIESupported)
check_pie_supported()

# Configure build types.
include(cmake/BuildTypes.cmake)

# Check unused linked libraries on executable and shared/module library targets.
include(PHP/LinkWhatYouUse)

# Enable C and POSIX extensions. The system extensions configuration will be
# defined in the configuration header main/php_config.h. The php-src code at the
# time of writing doesn't include this header in order to utilize them
# everywhere properly. The main/php_config.h should be the first inclusion
# before including any system header. Perhaps in php.h file. Until then, the
# compile definitions also need to be added when compiling and using PHP API.
# Mainly the _GNU_SOURCE.
include(PHP/SystemExtensions)
target_link_libraries(php_config INTERFACE PHP::SystemExtensions)

# Detect C standard library implementation.
include(PHP/StandardLibrary)

# Define GNU standard installation directories.
include(GNUInstallDirs)

# Set platform-specific configuration.
include(cmake/Platform.cmake)

# Set PHP configuration options and variables.
include(cmake/Configuration.cmake)

# Check requirements.
include(cmake/Requirements.cmake)

# Run PHP configuration checks.
include(cmake/ConfigureChecks.cmake)

# Check compilation options.
include(cmake/Flags.cmake)

add_subdirectory(sapi)
add_subdirectory(ext)
add_subdirectory(Zend)

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring PHP")
message(STATUS "===============")
message(STATUS "")

add_subdirectory(pear)
add_subdirectory(win32)
add_subdirectory(main)
add_subdirectory(scripts)

# Generate *_arginfo.h headers from *.stub.php sources.
include(PHP/Stubs)

# Configure PHP thread safety.
include(cmake/ThreadSafety.cmake)

################################################################################
# Execute all deferred calls. Calls are additionally sorted with natural
# comparison method by their IDs. If call hasn't set any ID number, CMake
# assigns it a default value of __<number>.
################################################################################

block()
  cmake_language(DEFER GET_CALL_IDS ids)
  list(SORT ids COMPARE NATURAL)
  foreach(id IN LISTS ids)
    cmake_language(DEFER GET_CALL ${id} call)
    list(POP_FRONT call command)
    message(VERBOSE "Executing deferred call: ${command}")
    cmake_language(CALL ${command} ${call})
    cmake_language(DEFER CANCEL_CALL ${id})
  endforeach()
endblock()

# Rebuild all targets as needed.
if(NOT PHP_HOST_FOUND)
  include(cmake/Rebuild.cmake)
endif()

################################################################################
# Configure PHP installation.
################################################################################

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  PHPConfigVersion.cmake
  VERSION "${PHP_VERSION}" # Set explicitly so also PHP_VERSION_LABEL is added.
  COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
  cmake/PHPConfig.cmake.in
  PHPConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  PATH_VARS
    PHP_EXTENSION_DIR
    PHP_INSTALL_INCLUDEDIR
)

add_library(php_extension INTERFACE)
add_library(PHP::Extension ALIAS php_extension)
set_target_properties(php_extension PROPERTIES EXPORT_NAME Extension)
target_include_directories(
  php_extension
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/main>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/TSRM>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Zend>
    $<INSTALL_INTERFACE:${PHP_INSTALL_INCLUDEDIR}>
    $<INSTALL_INTERFACE:${PHP_INSTALL_INCLUDEDIR}/main>
    $<INSTALL_INTERFACE:${PHP_INSTALL_INCLUDEDIR}/TSRM>
    $<INSTALL_INTERFACE:${PHP_INSTALL_INCLUDEDIR}/Zend>
)
target_compile_definitions(
  php_extension
  INTERFACE
  $<INSTALL_INTERFACE:HAVE_CONFIG_H;ZEND_COMPILE_DL_EXT>
  $<BUILD_INTERFACE:$<$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>:ZEND_COMPILE_DL_EXT>>
)

install(
  TARGETS php_extension
  EXPORT php_development_export
)

install(
  EXPORT php_development_export
  NAMESPACE PHP::
  FILE PHPDevelopmentTargets.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP/targets
  COMPONENT php-development
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/PHPConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/PHPConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  COMPONENT php-development
)

install(
  FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/CODING_STANDARDS.md
    ${CMAKE_CURRENT_SOURCE_DIR}/EXTENSIONS
    ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE
    ${CMAKE_CURRENT_SOURCE_DIR}/NEWS
    ${CMAKE_CURRENT_SOURCE_DIR}/README.md
    ${CMAKE_CURRENT_SOURCE_DIR}/README.REDIST.BINS
    ${CMAKE_CURRENT_SOURCE_DIR}/UPGRADING
    ${CMAKE_CURRENT_SOURCE_DIR}/UPGRADING.INTERNALS
  TYPE DOC
  COMPONENT php-doc
)

install(
  DIRECTORY cmake/modules
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP
  COMPONENT php-development
  PATTERN "FindPHP.cmake" EXCLUDE
)

if(PHP_ENABLE_CMAKE_EXPERIMENTAL_FEATURES)
  set(CMAKE_EXPERIMENTAL_EXPORT_PACKAGE_INFO "b80be207-778e-46ba-8080-b23bba22639e")

  install(
    PACKAGE_INFO PHP
    EXPORT php_development_export
  )
endif()

################################################################################
# Enable testing and configure test settings.
################################################################################

include(cmake/Testing.cmake)

################################################################################
# Enable and configure CPack module.
################################################################################

include(cmake/CPack.cmake)

################################################################################
# Print build configuration summary.
################################################################################

include(cmake/Summary.cmake)

message(
  STATUS
  [[License

This software is subject to the PHP License, available in this
distribution in the file LICENSE. By continuing this installation
process, you are bound by the terms of this license agreement.
If you do not agree with the terms of this license, you must abort
the installation process at this point.

Thank you for using PHP.
]]
)
