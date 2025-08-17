#[=============================================================================[
# PHP/Package/LibXml2

Finds or downloads the libxml2 library:

```cmake
include(PHP/Package/LibXml2)
```

This module first tries to find the libxml2 library on the system. If not found
it tries to download it from the upstream source and builds it together
with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/Package/LibXml2)
php_package_libxml2()
target_link_libraries(example PRIVATE LibXml2::LibXml2)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)
include(PHP/Package/_Internal)

set_package_properties(
  LibXml2
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxml2"
    DESCRIPTION "XML parser and toolkit"
)

# Minimum required version for the libxml2 dependency.
set(PHP_LIBXML2_MIN_VERSION 2.9.0)

# Download version when system dependency is not found.
set(PHP_LIBXML2_DOWNLOAD_VERSION 2.14.5)

set(PHP_LIBXML2_URL https://github.com/GNOME/libxml2/archive/refs/tags/v${PHP_LIBXML2_DOWNLOAD_VERSION}.tar.gz)

macro(php_package_libxml2)
  # LibXml2 depends on ZLIB.
  include(PHP/Package/ZLIB)

  FetchContent_Declare(
    LibXml2
    URL ${PHP_LIBXML2_URL}
    SOURCE_SUBDIR non-existing
    FIND_PACKAGE_ARGS ${PHP_LIBXML2_MIN_VERSION}
  )

  find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})

  if(PHP_USE_FETCHCONTENT)
    if(NOT LibXml2_FOUND)
      message(STATUS "Downloading ${PHP_LIBXML2_URL}")
    endif()

    FetchContent_MakeAvailable(LibXml2)

    if(NOT LibXml2_FOUND)
      _php_package_libxml2_init()
    endif()
  endif()

  get_property(PHP_LIBXML2_DOWNLOADED GLOBAL PROPERTY _PHP_LIBXML2_DOWNLOADED)

  if(PHP_LIBXML2_DOWNLOADED)
    set(LibXml2_VERSION ${PHP_LIBXML2_DOWNLOAD_VERSION})
  endif()
endmacro()

macro(_php_package_libxml2_init)
  set(
    options
      -DBUILD_SHARED_LIBS=OFF
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DLIBXML2_WITH_LZMA=OFF
      -DLIBXML2_WITH_PYTHON=OFF
  )

  if(PHP_ZLIB_DOWNLOADED)
    ExternalProject_Get_Property(ZLIB INSTALL_DIR)
    list(APPEND options "-DZLIB_ROOT=${INSTALL_DIR}")
  endif()

  # LibXml2 had hardcoded dl library check in versions <= 2.14.5.
  # https://gitlab.gnome.org/GNOME/libxml2/-/merge_requests/331
  if(
    CMAKE_SYSTEM_NAME STREQUAL "Haiku"
    AND PHP_LIBXML2_DOWNLOAD_VERSION VERSION_LESS_EQUAL 2.14.5
  )
    list(APPEND options "-DLIBXML2_WITH_MODULES=OFF")
  endif()

  ExternalProject_Add(
    LibXml2
    STEP_TARGETS configure build install
    SOURCE_DIR ${libxml2_SOURCE_DIR}
    BINARY_DIR ${libxml2_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/libxml2-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libxml2${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(LibXml2-configure ZLIB::ZLIB)

  ExternalProject_Get_Property(LibXml2 INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include/libxml2)

  add_library(LibXml2::LibXml2 STATIC IMPORTED GLOBAL)
  add_dependencies(LibXml2::LibXml2 LibXml2-install)

  set_target_properties(
    LibXml2::LibXml2
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include/libxml2
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libxml2${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  php_package_mark_as_found(LibXml2)

  define_property(
    GLOBAL
    PROPERTY _PHP_LIBXML2_DOWNLOADED
    BRIEF_DOCS "Marker that LibXml2 library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_LIBXML2_DOWNLOADED TRUE)
endmacro()

php_package_libxml2()
