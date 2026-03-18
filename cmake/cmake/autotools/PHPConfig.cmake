#[=============================================================================[
PHP package configuration file

Finds PHP, the general purpose scripting language:

  find_package(PHP [<version>] [COMPONENTS <components>...])

This file is part of the PHP Autotools build system. See FindPHP module for more
info.
#]=============================================================================]

################################################################################
# Create a user-friendly not-found message for unsupported CMake versions.
################################################################################

if(CMAKE_VERSION VERSION_LESS 4.3)
  string(
    CONCAT
    ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
    "${CMAKE_FIND_PACKAGE_NAME} ${${CMAKE_FIND_PACKAGE_NAME}_VERSION} requires "
    "CMake 4.3 or higher.\n"
    "You are running CMake version ${CMAKE_VERSION}"
  )

  set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)

  return()
endif()

cmake_minimum_required(VERSION 4.3...4.4)

# No components given, look for default components.
if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  set(${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS Interpreter Development)
endif()

################################################################################
# Use the find module to help find PHP.
################################################################################

include(${CMAKE_CURRENT_LIST_DIR}/FindPHP.cmake)

################################################################################
# Set result variables.
################################################################################

# Set path where additional PHP CMake modules are installed:
set(PHP_CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/modules")
list(APPEND CMAKE_MODULE_PATH ${PHP_CMAKE_MODULE_PATH})

################################################################################
# Include internal common modules when working with PHP.
################################################################################

if("Development" IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  include(PHP/Internal/Configuration)

  if(TARGET PHP::Extension)
    include(PHP/SystemExtensions)
    target_link_libraries(PHP::Extension INTERFACE PHP::SystemExtensions)
  endif()
endif()
