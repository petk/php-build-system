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
include(PHP/Package/libzip
target_link_libraries(php_ext_foo PRIVATE libzip::zip)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)

# Minimum required version for the libzip dependency.
# Also accepted libzip version ranges are from 0.11-1.7 with 1.3.1 and 1.7.0
# excluded due to upstream bugs.
set(PHP_libzip_MIN_VERSION 1.7.1)

# Download version when system dependency is not found.
set(PHP_libzip_DOWNLOAD_VERSION 1.11.4)

macro(php_package_libzip_find)
  if(TARGET libzip::zip)
    set(libzip_FOUND TRUE)
    get_property(libzip_DOWNLOADED GLOBAL PROPERTY _PHP_libzip_DOWNLOADED)
    get_property(libzip_VERSION GLOBAL PROPERTY _PHP_libzip_VERSION)
  else()
    # libzip depends on ZLIB
    include(PHP/Package/ZLIB)

    find_package(libzip ${PHP_libzip_MIN_VERSION})

    if(NOT libzip_FOUND)
      find_package(libzip 1.3.2...1.6.999)
    endif()

    if(NOT libzip_FOUND)
      find_package(libzip 0.11...1.3.0)
    endif()

    if(NOT libzip_FOUND)
      _php_package_libzip_download()
    else()
      set_property(
        GLOBAL PROPERTY _PHP_libzip_VERSION ${libzip_VERSION}
      )
    endif()
  endif()
endmacro()

macro(_php_package_libzip_download)
  message(STATUS "Downloading libzip ${PHP_libzip_DOWNLOAD_VERSION}")

  FetchContent_Declare(
    libzip
    URL https://github.com/nih-at/libzip/archive/refs/tags/v${PHP_libzip_DOWNLOAD_VERSION}.tar.gz
    SOURCE_SUBDIR non-existing
    OVERRIDE_FIND_PACKAGE
  )

  FetchContent_MakeAvailable(libzip)

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")
  list(APPEND options -DBUILD_SHARED_LIBS=OFF)

  if(ZLIB_DOWNLOADED)
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

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "libzip")
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
  set(libzip_FOUND TRUE)

  define_property(
    GLOBAL
    PROPERTY _PHP_libzip_DOWNLOADED
    BRIEF_DOCS "Marker that libzip library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_libzip_DOWNLOADED TRUE)
  set(libzip_DOWNLOADED TRUE)

  set_property(
    GLOBAL PROPERTY _PHP_libzip_VERSION ${PHP_libzip_DOWNLOAD_VERSION}
  )
  set(libzip_VERSION ${PHP_libzip_DOWNLOAD_VERSION})
endmacro()

macro(_php_package_libzip_set_vars)

endmacro()

php_package_libzip_find()
