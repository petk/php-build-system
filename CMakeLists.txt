#[=============================================================================[
Wrapper for integrating PHP sources with CMake

This file uses the FetchContent module to download the PHP source code tarball,
integrate CMake files, and apply necessary patches to enable building PHP with
CMake.

While not part of the CMake-based build system itself, this file serves as a
wrapper to bridge the upstream PHP source code with the CMake-based build system
in this repository located at the cmake directory, streamlining the integration
process.

Usage:

  cmake -B <build-dir> [<options>...]

Configuration variables:

  PHP_VERSION_DOWNLOAD
    PHP version to download. Format: <major>.<minor>[.<patch>][<extra>]

For example:

  cmake -B <build-dir>
    will download PHP-8.6 Git branch archive from GitHub. Same as:
      cmake -B <build-dir> -D PHP_VERSION_DOWNLOAD=8.6-dev

  cmake -B <build-dir> -D PHP_VERSION_DOWNLOAD=8.6
    will download latest stable 8.6 release tarball from php.net.

  cmake -B <build-dir> -D PHP_VERSION_DOWNLOAD=8.6.0
    will download specific PHP version tarball from php.net.

Other PHP-related configuration variables can be passed similarly. For example:

  cmake -B <build-dir> -D PHP_VERSION_DOWNLOAD=8.6 -D PHP_THREAD_SAFETY=ON
    will download latest PHP 8.6 tarball and enable PHP thread safety (ZTS).

After configuration and generation phase is complete, PHP can be built by:

  cmake --build <build-dir> -j
    and the built PHP binary should be then ready to run:
      <build-dir>/php/sapi/cli/php -v

PHP configuration can be also specified with the CMake presets:

  cmake --preset <preset>

For example:

  cmake --preset all-enabled
  cmake --build --preset all-enabled -j

See build system documentation for available PHP configuration variables and
further information.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

include(cmake/cmake/modules/PHP/Internal/DisableInSourceBuild.cmake)

project(
  PhpBuildSystem
  VERSION 8.6
  DESCRIPTION "CMake-based PHP build system"
  HOMEPAGE_URL "https://github.com/petk/php-build-system"
  LANGUAGES NONE
)

# Configuration.
block(PROPAGATE php_url)
  set(
    CACHE{PHP_VERSION_DOWNLOAD}
    TYPE STRING
    HELP "The PHP version to download"
    VALUE "${PROJECT_VERSION}-dev"
  )
  mark_as_advanced(PHP_VERSION_DOWNLOAD)

  # PHP <major>.<minor> version currently in development (the master branch).
  set(php_development_branch 8.6)

  # Validate PHP version.
  if(NOT PHP_VERSION_DOWNLOAD MATCHES [[^[0-9]+\.[0-9]+(\.[0-9]+|-dev|$)]])
    message(
      FATAL_ERROR
      "Unsupported PHP version format given: ${PHP_VERSION_DOWNLOAD}\n"
      "Expected PHP version format is <major>.<minor>[.<patch>][<extra>]"
    )
  elseif(NOT PHP_VERSION_DOWNLOAD MATCHES "^${PROJECT_VERSION}(\\.[0-9]+|-dev|$)")
    string(REGEX MATCH [[^([0-9]+\.[0-9]+)]] _ "${PHP_VERSION_DOWNLOAD}")
    message(
      FATAL_ERROR
      "Version ${PHP_VERSION_DOWNLOAD} is not supported by the current Git "
      "branch of the php-build-system repository. Please checkout the "
      "PHP-${CMAKE_MATCH_1} Git branch if it exists:\n"
      "  git checkout PHP-${CMAKE_MATCH_1}"
    )
  endif()

  set(branch "")
  set(version "")

  if(PHP_VERSION_DOWNLOAD MATCHES "^${php_development_branch}(-dev)?(.*)$")
    if(CMAKE_MATCH_2)
      message(
        WARNING
        "PHP ${php_development_branch} is marked as development branch. "
        "Version has been set to ${php_development_branch}-dev"
      )
    endif()
    set(branch "master")
  elseif(PHP_VERSION_DOWNLOAD MATCHES [[^([0-9]+\.[0-9]+)-dev$]])
    set(branch "PHP-${CMAKE_MATCH_1}")
  else()
    # Get the latest PHP stable version from JSON API.
    string(TIMESTAMP timestamp %s)
    set(file "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php-${timestamp}.json")
    file(
      DOWNLOAD
      "https://www.php.net/releases/?json&version=${PHP_VERSION_DOWNLOAD}"
      "${file}"
    )
    file(READ "${file}" json)
    file(REMOVE "${file}")

    string(JSON version ERROR_VARIABLE error GET "${json}" version)

    if(PHP_VERSION_DOWNLOAD MATCHES [[^[0-9]+\.[0-9]+$]] AND error)
      message(
        WARNING
        "Latest PHP version could not be determined. Setting version to "
        "${PROJECT_VERSION}-dev."
      )
      set(version "")
      set(branch "PHP-${PROJECT_VERSION}")
    elseif(NOT version)
      message(
        FATAL_ERROR
        "PHP version ${PHP_VERSION_DOWNLOAD} could not be found. Either this "
        "version is not available for download or some error happened. "
        "Available versions can be found at:\n"
        "  https://www.php.net/downloads.php"
      )
    endif()
  endif()

  if(branch)
    set(
      php_url
      https://github.com/php/php-src/archive/refs/heads/${branch}.tar.gz
    )
  elseif(version)
    set(php_url https://www.php.net/distributions/php-${version}.tar.gz)
  else()
    message(FATAL_ERROR "Something went wrong.")
  endif()
endblock()

include(FetchContent)

# Configure PHP project.
if(NOT DEFINED PHP_TESTING)
  set(PHP_TESTING "${PROJECT_IS_TOP_LEVEL}")
endif()

if(PHP_TESTING)
  enable_testing()
endif()

FetchContent_Declare(
  php
  URL ${php_url}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/php-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/php
  PATCH_COMMAND
    ${CMAKE_COMMAND}
    -P
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PhpBuildSystem/patch.cmake
)

# Create script for the FetchContent_Declare(PATCH_COMMAND).
file(
  CONFIGURE
  OUTPUT CMakeFiles/PhpBuildSystem/patch.cmake
  CONTENT [=[
    message(STATUS "Adding CMake files to PHP sources")
    file(
      COPY
      "@CMAKE_CURRENT_SOURCE_DIR@/cmake/"
      DESTINATION "@CMAKE_CURRENT_BINARY_DIR@/php-src"
    )

    string(REGEX MATCH [[^([0-9]+\.[0-9]+)]] _ "@PROJECT_VERSION@")
    file(
      GLOB
      patches
      "@CMAKE_CURRENT_SOURCE_DIR@/patches/${CMAKE_MATCH_1}/*.patch"
    )

    if(NOT patches)
      return()
    endif()

    find_package(Git QUIET)
    if(NOT Git_FOUND)
      find_package(Patch QUIET)
    endif()

    if(NOT Git_FOUND AND NOT Patch_FOUND)
      message(WARNING "Patches not applied. Install Git or the patch command.")
      return()
    endif()

    message(STATUS "Applying patches to PHP sources\n")

    if(Git_FOUND)
      # Add .git directory to be able to apply patches.
      execute_process(
        COMMAND ${GIT_EXECUTABLE} init
        WORKING_DIRECTORY "@CMAKE_CURRENT_BINARY_DIR@/php-src"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        ERROR_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
      )
      if(NOT result EQUAL 0)
        message(WARNING "Failed to create .git directory:\n${output}\n${error}")
      endif()

      execute_process(
        COMMAND ${GIT_EXECUTABLE} apply --ignore-whitespace ${patches}
        WORKING_DIRECTORY "@CMAKE_CURRENT_BINARY_DIR@/php-src"
        RESULT_VARIABLE result
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        ERROR_STRIP_TRAILING_WHITESPACE
        OUTPUT_QUIET
      )
      if(NOT result EQUAL 0)
        message(WARNING "Failed to apply patches:\n${output}\n${error}.")
      endif()

      # Clean temporary .git directory. Checks are done as safeguards.
      if(
        IS_DIRECTORY "@CMAKE_CURRENT_BINARY_DIR@/php-src/.git"
        AND EXISTS "@CMAKE_CURRENT_BINARY_DIR@/php-src/main/php_version.h"
        AND EXISTS "@CMAKE_CURRENT_BINARY_DIR@/php-src/CMakeLists.txt"
      )
        file(REMOVE_RECURSE "@CMAKE_CURRENT_BINARY_DIR@/php-src/.git/")
      endif()
    elseif(Patch_FOUND)
      foreach(patch IN LISTS patches)
        execute_process(
          COMMAND ${Patch_EXECUTABLE} -p1 -i "${patch}"
          WORKING_DIRECTORY "@CMAKE_CURRENT_BINARY_DIR@/php-src"
          RESULT_VARIABLE result
          OUTPUT_VARIABLE output
          ERROR_VARIABLE error
          ERROR_STRIP_TRAILING_WHITESPACE
          OUTPUT_QUIET
        )
        if(NOT result EQUAL 0)
          cmake_path(GET patch FILENAME filename)
          message(WARNING "Patch ${filename} failed:\n${output}\n${error}\n")
        endif()
      endforeach()
    endif()
  ]=]
  @ONLY
)

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_BINARY_DIR
  BASE_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE relative_dir
)
message(STATUS "Downloading ${php_url} to ${relative_dir}")
FetchContent_MakeAvailable(php)
