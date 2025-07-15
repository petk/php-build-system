#[=============================================================================[
# PHP/Package/Zlib

Finds or downloads the zlib library:

```cmake
include(PHP/Package/Zlib)
```

This module is a wrapper for finding the `ZLIB` library. It first tries to find
the `ZLIB` library on the system. If not successful it tries to download it from
the upstream source with `ExternalProject` module and builds it together with
the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindZLIB.html

## Examples

Basic usage:

```cmake
include(PHP/Package/ZLIB)
target_link_libraries(php_ext_foo PRIVATE ZLIB::ZLIB)
```
#]=============================================================================]

include(FeatureSummary)
include(ExternalProject)

set_package_properties(
  ZLIB
  PROPERTIES
    URL "https://zlib.net/"
    DESCRIPTION "Compression library"
)

# Minimum required version for the zlib dependency.
set(PHP_ZLIB_MIN_VERSION 1.2.0.4)

# Download version when system dependency is not found.
set(PHP_ZLIB_DOWNLOAD_VERSION 1.3.1)

if(TARGET ZLIB::ZLIB)
  set(ZLIB_FOUND TRUE)
  get_property(ZLIB_DOWNLOADED GLOBAL PROPERTY _PHP_ZLIB_DOWNLOADED)
  return()
endif()

find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})

if(NOT ZLIB_FOUND)
  message(
    STATUS
    "ZLIB ${PHP_ZLIB_DOWNLOAD_VERSION} will be downloaded at build phase"
  )

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  if(PHP_ZLIB_DOWNLOAD_VERSION VERSION_LESS_EQUAL 1.3.1)
    list(APPEND options -DZLIB_BUILD_EXAMPLES=OFF)
  endif()

  if(PHP_ZLIB_DOWNLOAD_VERSION VERSION_GREATER 1.3.1)
    list(APPEND options -DZLIB_BUILD_TESTING=OFF)
  endif()

  ExternalProject_Add(
    ZLIB
    STEP_TARGETS build install
    URL
      https://github.com/madler/zlib/releases/download/v${PHP_ZLIB_DOWNLOAD_VERSION}/zlib-${PHP_ZLIB_DOWNLOAD_VERSION}.tar.gz
    CMAKE_ARGS ${options}
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib-installation
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libz${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound ZLIB)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ZLIB)
  endblock()

  ExternalProject_Get_Property(ZLIB INSTALL_DIR)

  # Bypass issue with non-existing include directory for the imported target.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(ZLIB::ZLIB STATIC IMPORTED GLOBAL)
  set_target_properties(
    ZLIB::ZLIB
    PROPERTIES
      IMPORTED_LOCATION "${INSTALL_DIR}/lib/libz${CMAKE_STATIC_LIBRARY_SUFFIX}"
      INTERFACE_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include"
  )
  add_dependencies(ZLIB::ZLIB ZLIB-install)

  # Mark package as found.
  set(ZLIB_FOUND TRUE)

  define_property(
    GLOBAL
    PROPERTY _PHP_ZLIB_DOWNLOADED
    BRIEF_DOCS "Marker that zlib library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_ZLIB_DOWNLOADED TRUE)
  set(ZLIB_DOWNLOADED TRUE)
endif()
