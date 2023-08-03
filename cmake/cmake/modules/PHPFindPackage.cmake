#[=============================================================================[
Checks whether required package is available on the system.

function:
  php_find_package(NAME <package-name> VERSION <package-version> [QUIET])

Arguments:
  QUIET
    When searching for package, no output is emitted.

The module sets the following variables:

``<package_name>_FOUND``
  Defined to 1 if package is found.
``<package_name>_LIBRARIES``
  Name of package libraries that can be linked to target.
``<package_name>_CFLAGS``
  List of found package compiler flags that can be appended to target.
]=============================================================================]#

function(php_find_package)
  set(oneValueArgs NAME VERSION)
  set(options QUIET)

  cmake_parse_arguments(PHP_PACKAGE "${options}" "${oneValueArgs}" "" ${ARGN})

  # Check if the NAME argument is provided.
  if(NOT PHP_PACKAGE_NAME)
    message(FATAL_ERROR "php_find_package expects the NAME argument. Please use 'NAME' in front of the package name.")
  endif()

  # Check if the VERSION argument is provided.
  if(NOT PHP_PACKAGE_VERSION)
    message(FATAL_ERROR "php_find_package expects the VERSION argument. Please use 'VERSION' in front of the package version.")
  endif()

  if(NOT ${PHP_PACKAGE_QUIET})
    set(PHP_PACKAGE_QUIET "")
  endif()

  # First, try if it can be found using CMake packages.
  find_package(${PHP_PACKAGE_NAME} ${PHP_PACKAGE_VERSION} ${PHP_PACKAGE_QUIET})

  # Then resort to pkg-config.
  if(NOT ${PHP_PACKAGE_NAME}_FOUND)
    find_package(PkgConfig ${PHP_PACKAGE_QUIET})

    if(PKG_CONFIG_FOUND)
      pkg_search_module(${PHP_PACKAGE_NAME} ${PHP_PACKAGE_NAME}>=${PHP_PACKAGE_VERSION} ${PHP_PACKAGE_QUIET})
    endif()
  endif()

  if(NOT ${PHP_PACKAGE_NAME}_FOUND)
    message(FATAL_ERROR "${PHP_PACKAGE_NAME} not found on this system.")
  endif()

  set(${PHP_PACKAGE_NAME}_FOUND 1 CACHE INTERNAL "Defined to 1 if ${PHP_PACKAGE_NAME} is available")

  message(STATUS "Package name: ${PHP_PACKAGE_NAME}")
  message(STATUS "${PHP_PACKAGE_NAME} version: ${${PHP_PACKAGE_NAME}_VERSION}")
  message(STATUS "${PHP_PACKAGE_NAME} libraries: ${${PHP_PACKAGE_NAME}_LIBRARIES}")
  message(STATUS "${PHP_PACKAGE_NAME} compiler flags: ${${PHP_PACKAGE_NAME}_CFLAGS}")
endfunction()
