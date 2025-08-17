#[=============================================================================[
# PHP/Package/Zlib

Finds or downloads the zlib library:

```cmake
include(PHP/Package/Zlib)
```

This module is a wrapper for finding the ZLIB library. It first tries to find
the `ZLIB` library on the system. If not successful it tries to download it from
the upstream source and builds it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindZLIB.html

## Examples

Basic usage:

```cmake
include(PHP/Package/ZLIB)
php_package_zlib()
target_link_libraries(php_ext_foo PRIVATE ZLIB::ZLIB)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)
include(PHP/Package/_Internal)

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

set(
  PHP_ZLIB_URL
  https://github.com/madler/zlib/archive/refs/tags/v${PHP_ZLIB_DOWNLOAD_VERSION}.tar.gz
)

macro(php_package_zlib)
  FetchContent_Declare(
    ZLIB
    URL ${PHP_ZLIB_URL}
    SOURCE_SUBDIR non-existing
    FIND_PACKAGE_ARGS ${PHP_ZLIB_MIN_VERSION}
  )

  find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})

  if(PHP_USE_FETCHCONTENT)
    if(NOT ZLIB_FOUND)
      message(STATUS "Downloading ${PHP_ZLIB_URL}")
    endif()

    FetchContent_MakeAvailable(ZLIB)

    if(NOT ZLIB_FOUND)
      _php_package_zlib_init()
    endif()
  endif()

  get_property(PHP_ZLIB_DOWNLOADED GLOBAL PROPERTY _PHP_ZLIB_DOWNLOADED)

  if(PHP_ZLIB_DOWNLOADED)
    set(ZLIB_VERSION ${PHP_ZLIB_DOWNLOAD_VERSION})
  endif()
endmacro()

macro(_php_package_zlib_init)
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

  php_package_mark_as_found(ZLIB)

  define_property(
    GLOBAL
    PROPERTY _PHP_ZLIB_DOWNLOADED
    BRIEF_DOCS "Marker that zlib library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_ZLIB_DOWNLOADED TRUE)
endmacro()

php_package_zlib()
