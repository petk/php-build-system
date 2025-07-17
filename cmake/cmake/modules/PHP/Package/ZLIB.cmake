#[=============================================================================[
# PHP/Package/Zlib

Finds or downloads the zlib library:

```cmake
include(PHP/Package/Zlib)
```

This module is a wrapper for finding the `ZLIB` library. It first tries to find
the `ZLIB` library on the system. If not successful it tries to download it from
the upstream source and builds it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindZLIB.html

## Examples

Basic usage:

```cmake
include(PHP/Package/ZLIB)
php_package_zlib_find()
target_link_libraries(php_ext_foo PRIVATE ZLIB::ZLIB)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)

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

macro(php_package_zlib_find)
  if(TARGET ZLIB::ZLIB)
    set(ZLIB_FOUND TRUE)
    get_property(ZLIB_DOWNLOADED GLOBAL PROPERTY _PHP_ZLIB_DOWNLOADED)
  else()
    find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})

    if(NOT ZLIB_FOUND)
      _php_package_zlib_download()
    endif()
  endif()
endmacro()

macro(_php_package_zlib_download)
  message(STATUS "Downloading ZLIB ${PHP_ZLIB_DOWNLOAD_VERSION}")

  FetchContent_Declare(
    ZLIB
    URL https://github.com/madler/zlib/archive/refs/tags/v${PHP_ZLIB_DOWNLOAD_VERSION}.tar.gz
    SOURCE_SUBDIR non-existing
    OVERRIDE_FIND_PACKAGE
  )

  FetchContent_MakeAvailable(ZLIB)

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
    SOURCE_DIR ${zlib_SOURCE_DIR}
    BINARY_DIR ${zlib_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/zlib-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libz${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  ExternalProject_Get_Property(ZLIB INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(ZLIB::ZLIB STATIC IMPORTED GLOBAL)
  add_dependencies(ZLIB::ZLIB ZLIB-install)
  set_target_properties(
    ZLIB::ZLIB
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libz${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "ZLIB")
    get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound ${package})
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${packagesNotFound})
    get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
    list(FIND packagesFound ${package} found)
    if(found EQUAL -1)
      set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${package})
    endif()
  endblock()

  # Mark package as found.
  set(ZLIB_FOUND TRUE)

  define_property(
    GLOBAL
    PROPERTY _PHP_ZLIB_DOWNLOADED
    BRIEF_DOCS "Marker that zlib library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_ZLIB_DOWNLOADED TRUE)
  set(ZLIB_DOWNLOADED TRUE)
endmacro()

php_package_zlib_find()
