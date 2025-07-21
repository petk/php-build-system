#[=============================================================================[
# PHP/Package/LibXslt

Finds or downloads the libxslt library:

```cmake
include(PHP/Package/LibXslt)
```

This module first tries to find the libxslt library on the system. If not found
it tries to download it from the upstream source and builds it together
with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindLibXslt.html

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/Package/LibXslt)
php_package_libxslt()
target_link_libraries(example PRIVATE LibXslt::LibXslt)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)
include(PHP/Package/_Internal)

set_package_properties(
  LibXslt
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxslt"
    DESCRIPTION "XSLT processor library"
)

# Minimum required version for the libxslt dependency.
set(PHP_LIBXSLT_MIN_VERSION 1.1.0)

# Download version when system dependency is not found.
set(PHP_LIBXSLT_DOWNLOAD_VERSION 1.1.43)

set(PHP_LIBXSLT_URL https://github.com/GNOME/libxslt/archive/refs/tags/v${PHP_LIBXSLT_DOWNLOAD_VERSION}.tar.gz)

macro(php_package_libxslt)
  # LibXslt depends on LibXml2.
  include(PHP/Package/LibXml2)

  FetchContent_Declare(
    LibXslt
    URL ${PHP_LIBXSLT_URL}
    SOURCE_SUBDIR non-existing
    FIND_PACKAGE_ARGS ${PHP_LIBXSLT_MIN_VERSION}
  )

  find_package(LibXslt ${PHP_LIBXSLT_MIN_VERSION})

  if(PHP_USE_FETCHCONTENT)
    if(NOT LibXslt_FOUND)
      message(STATUS "Downloading ${PHP_LIBXSLT_URL}")
    endif()

    FetchContent_MakeAvailable(LibXslt)

    if(NOT LibXslt_FOUND)
      _php_package_libxslt_init()
    endif()
  endif()

  get_property(PHP_LIBXSLT_DOWNLOADED GLOBAL PROPERTY _PHP_LIBXSLT_DOWNLOADED)

  if(PHP_LIBXSLT_DOWNLOADED)
    set(LibXslt_VERSION ${PHP_LIBXSLT_DOWNLOAD_VERSION})
  endif()
endmacro()

macro(_php_package_libxslt_init)
  set(
    options
      -DBUILD_SHARED_LIBS=OFF
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DLIBXSLT_WITH_PYTHON=OFF
      -DLIBXSLT_WITH_TESTS=OFF
  )

  if(PHP_LIBXML2_DOWNLOADED)
    ExternalProject_Get_Property(LibXml2 INSTALL_DIR)
    list(APPEND options "-DLIBXML2_ROOT=${INSTALL_DIR}")
  endif()

  ExternalProject_Add(
    LibXslt
    STEP_TARGETS configure build install
    SOURCE_DIR ${libxslt_SOURCE_DIR}
    BINARY_DIR ${libxslt_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/libxslt-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libxslt${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(LibXslt-configure LibXml2::LibXml2)

  ExternalProject_Get_Property(LibXslt INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include/libxslt)

  add_library(LibXslt::LibXslt STATIC IMPORTED GLOBAL)
  add_dependencies(LibXslt::LibXslt LibXslt-install)

  set_target_properties(
    LibXslt::LibXslt
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include/libxslt
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libxslt${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  php_package_mark_as_found(LibXslt)

  define_property(
    GLOBAL
    PROPERTY _PHP_LIBXSLT_DOWNLOADED
    BRIEF_DOCS "Marker that LibXslt library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_LIBXSLT_DOWNLOADED TRUE)
endmacro()

php_package_libxslt()
