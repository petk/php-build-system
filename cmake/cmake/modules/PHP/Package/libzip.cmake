#[=============================================================================[
# PHP/Package/libzip

Finds or downloads libzip library:

```cmake
include(PHP/Package/libzip
```

This module first tries to find the libzip library on the system. If not found
it downloads it from the upstream source and builds it together with the build.

## Examples

Basic usage:

```cmake
include(PHP/Package/libzip)
php_package_libzip()
target_link_libraries(php_ext_foo PRIVATE libzip::zip)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)
include(PHP/Package/_Internal)

# Minimum required version for the libzip dependency.
# Also accepted libzip version ranges are from 0.11-1.7 with 1.3.1 and 1.7.0
# excluded due to upstream bugs.
set(PHP_LIBZIP_MIN_VERSION 1.7.1)

# Download version when system dependency is not found.
set(PHP_LIBZIP_DOWNLOAD_VERSION 1.11.4)

set(
  PHP_LIBZIP_URL
  https://github.com/nih-at/libzip/archive/refs/tags/v${PHP_libzip_DOWNLOAD_VERSION}.tar.gz
)

macro(php_package_libzip)
  # libzip depends on ZLIB
  include(PHP/Package/ZLIB)

  FetchContent_Declare(
    libzip
    URL ${PHP_LIBZIP_URL}
    SOURCE_SUBDIR non-existing
    FIND_PACKAGE_ARGS ${PHP_LIBZIP_MIN_VERSION}
  )

  find_package(libzip ${PHP_LIBZIP_MIN_VERSION})

  if(NOT libzip_FOUND)
    find_package(libzip 1.3.2...1.6.999)
  endif()

  if(NOT libzip_FOUND)
    find_package(libzip 0.11...1.3.0)
  endif()

  if(PHP_USE_FETCHCONTENT)
    if(NOT libzip_FOUND)
      message(STATUS "Downloading ${PHP_LIBZIP_URL}")
    endif()

    FetchContent_MakeAvailable(libzip)

    if(NOT libzip_FOUND)
      _php_package_libzip_init()
    endif()
  endif()

  get_property(PHP_LIBZIP_DOWNLOADED GLOBAL PROPERTY _PHP_LIBZIP_DOWNLOADED)

  if(PHP_LIBZIP_DOWNLOADED)
    set(libzip_VERSION ${PHP_libzip_DOWNLOAD_VERSION})
  endif()
endmacro()

macro(_php_package_libzip_init)
  set(
    options
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DBUILD_DOC=OFF
      -DBUILD_EXAMPLES=OFF
      -DBUILD_REGRESS=OFF
      -DBUILD_SHARED_LIBS=OFF
      -DBUILD_TOOLS=OFF
  )

  if(
    PHP_LIBZIP_DOWNLOAD_VERSION VERSION_GREATER_EQUAL 1.10
    AND CMAKE_SYSTEM_NAME STREQUAL "Windows"
  )
    list(APPEND options -DENABLE_FDOPEN=OFF)
  endif()

  if(PHP_LIBZIP_DOWNLOAD_VERSION VERSION_GREATER_EQUAL 1.11)
    list(APPEND options -DBUILD_OSSFUZZ=OFF)
  endif()

  if(PHP_ZLIB_DOWNLOADED)
    ExternalProject_Get_Property(ZLIB INSTALL_DIR)
    list(APPEND options "-DZLIB_ROOT=${INSTALL_DIR}")
  endif()

  ExternalProject_Add(
    libzip
    STEP_TARGETS build install
    SOURCE_DIR ${libzip_SOURCE_DIR}
    BINARY_DIR ${libzip_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/libzip-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libzip${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(libzip ZLIB::ZLIB)

  ExternalProject_Get_Property(libzip INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(libzip::zip STATIC IMPORTED GLOBAL)
  add_dependencies(libzip::zip libzip-install)
  set_target_properties(
    libzip::zip
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libzip${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  php_package_mark_as_found(libzip)

  define_property(
    GLOBAL
    PROPERTY _PHP_LIBZIP_DOWNLOADED
    BRIEF_DOCS "Marker that libzip library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_LIBZIP_DOWNLOADED TRUE)
endmacro()

php_package_libzip()
