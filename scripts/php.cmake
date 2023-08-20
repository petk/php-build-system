#[=============================================================================[
Standalone CMake helper script that downloads PHP tarball, applies PHP source
code patches and adds CMake files for running CMake commands on the PHP sources.

After running this script, there will be tarball file and extracted directory
available.

This script is not part of the CMake build system itself but is only a simple
wrapper to be able to use CMake in PHP sources and written in CMake way to be
as portable as possible on different systems.

Variables:
  PHP
    PHP version to download in form of {MAJOR}.{MINOR}.{PATCH}{EXTRA}

Usage examples:
  cmake -DPHP=8.3.0beta3 -P scripts/php.cmake
#]=============================================================================]

set(PHP "8.3.0beta3" CACHE STRING "PHP version")

if(NOT PHP MATCHES "^8\\.[0-9]\\.[0-9]+[a-zA-Z0-9\\-]*$")
  message(FATAL_ERROR "PHP version should match pattern {MAJOR}.{MINOR}.{PATCH}{EXTRA}")
endif()

set(PHP_VERSION "${PHP}")

if(PHP_VERSION MATCHES ".*-dev")
  set(URL "https://github.com/php/php-src/archive/refs/heads/master.tar.gz")
else()
  set(URL "https://downloads.php.net/~eric/php-${PHP_VERSION}.tar.gz")
endif()

set(PHP_TARBALL "php-${PHP_VERSION}.tar.gz")
set(PHP_DIRECTORY "php-${PHP_VERSION}")

if(EXISTS "${PHP_DIRECTORY}")
  message(FATAL_ERROR "To continue, please remove previous existing directory ${PHP_DIRECTORY}")
endif()

function(check_url)
  unset(URL_FOUND)

  set(check_url_command curl --silent --head --fail ${ARGN})

  execute_process(
    COMMAND ${check_url_command}
    RESULT_VARIABLE URL_FOUND
    OUTPUT_QUIET
  )

  if(URL_FOUND EQUAL 0)
    set(URL_FOUND 1 CACHE INTERNAL "URL found")
  else()
    set(URL_FOUND 0 CACHE INTERNAL "URL not found")
  endif()
endfunction()

# Download PHP tarball.
if(NOT EXISTS ${PHP_TARBALL})
  message(STATUS "Downloading PHP ${PHP_VERSION}")

  check_url(${URL})

  if(NOT URL_FOUND)
    message(FATAL_ERROR "URL ${URL} returned error")
  endif()

  file(DOWNLOAD ${URL} ${PHP_TARBALL} SHOW_PROGRESS)
endif()

file(ARCHIVE_EXTRACT INPUT ${PHP_TARBALL})

if(EXISTS php-src-master)
  file(RENAME php-src-master ${PHP_DIRECTORY})
endif()

# Add CMake files.
file(INSTALL cmake/ DESTINATION ${PHP_DIRECTORY})

# Apply patches for php-src.
file(GLOB_RECURSE patches "patches/*.patch")

# Check if git command is available.
find_program(GIT_EXECUTABLE git)

if(NOT GIT_EXECUTABLE)
  message(FATAL_ERROR "Git executable not found. Cannot apply patches for PHP source code.")
endif()

# Add .git directory to be able to apply patches.
execute_process(
  COMMAND ${GIT_EXECUTABLE} init
  WORKING_DIRECTORY ${PHP_DIRECTORY}
  RESULT_VARIABLE result
  ERROR_VARIABLE error
  ERROR_STRIP_TRAILING_WHITESPACE
  OUTPUT_QUIET
)

if(NOT result EQUAL 0)
  message(FATAL_ERROR "${output}\n${error}")
endif()

# Define the command to apply the patches using git.
set(patch_command ${GIT_EXECUTABLE} apply --ignore-whitespace)

foreach(patch ${patches})
  # Execute the patch command.
  execute_process(
    COMMAND ${patch_command} "${patch}"
    WORKING_DIRECTORY ${PHP_DIRECTORY}
    RESULT_VARIABLE patch_result
  )

  cmake_path(GET patch FILENAME patch_filename)

  if(patch_result EQUAL 0)
    message(STATUS "Patch ${patch_filename} applied successfully.")
  else()
    message(WARNING "Failed to apply patch ${patch_filename}.")
  endif()
endforeach()

# Patch PHP version in main CMakeLists.txt file to match the one downloaded.
message(STATUS "Patching version in ${PHP_DIRECTORY}/CMakeLists.txt")

string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)([a-zA-Z0-9\\-]*)$" _ ${PHP_VERSION})

set(PHP_VERSION_MAJOR ${CMAKE_MATCH_1})
set(PHP_VERSION_MINOR ${CMAKE_MATCH_2})
set(PHP_VERSION_PATCH ${CMAKE_MATCH_3})
set(PHP_VERSION_LABEL ${CMAKE_MATCH_4})

string(CONCAT PHP_VERSION_MAIN "${PHP_VERSION_MAJOR}" "." "${PHP_VERSION_MINOR}" "." "${PHP_VERSION_PATCH}")

file(READ "${PHP_DIRECTORY}/CMakeLists.txt" file_contents)
string(REPLACE "VERSION 8.3.0" "VERSION ${PHP_VERSION_MAIN}" file_contents ${file_contents})
string(REPLACE "set(PHP_VERSION_LABEL \"-dev\"" "set(PHP_VERSION_LABEL \"${PHP_VERSION_LABEL}\"" file_contents ${file_contents})
file(WRITE "${PHP_DIRECTORY}/CMakeLists.txt" "${file_contents}")

message("
${PHP_DIRECTORY} directory is now ready to use")
