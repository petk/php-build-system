#[=============================================================================[
# PHP/Package/libzip

Finds and downloads `libzip` library:

```cmake
include(PHP/Package/libzip
```

This module first tries to find the `libzip` library on the system. If not
successful it tries to download it from the upstream source with
`ExternalProject` module and build it together with the PHP build.

## Examples

Basic usage:

```cmake
include(PHP/Package/libzip
target_link_libraries(php_ext_foo PRIVATE libzip::libzip)
```
#]=============================================================================]

include(FeatureSummary)
include(FetchContent)

set_package_properties(
  libzip
  PROPERTIES
    URL "https://libzip.org/"
    DESCRIPTION "Library for reading and writing ZIP compressed archives"
)

# Minimum required version for the libzip dependency.
set(PHP_libzip_MIN_VERSION 1.7.1)

# Download version when system dependency is not found.
set(PHP_libzip_DOWNLOAD_VERSION 1.11.4)

find_package(libzip ${PHP_libzip_MIN_VERSION})

if(NOT libzip_FOUND)
  include(PHP/Package/ZLIB)

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  if(ZLIB_DOWNLOADED)
    ExternalProject_Get_Property(ZLIB INSTALL_DIR)
    list(APPEND options "-DCMAKE_PREFIX_PATH=${INSTALL_DIR}")
  endif()

  ExternalProject_Add(
    libzip
    STEP_TARGETS build install
    URL
      https://github.com/nih-at/libzip/releases/download/v${PHP_libzip_DOWNLOAD_VERSION}/libzip-${PHP_libzip_DOWNLOAD_VERSION}.tar.gz
    CMAKE_ARGS ${options}
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/libzip-installation
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libzip${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(libzip ZLIB::ZLIB)

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

  ExternalProject_Get_Property(libzip INSTALL_DIR)

  # Bypass issue with non-existing include directory for the imported target.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(libzip::libzip STATIC IMPORTED GLOBAL)
  set_target_properties(
    libzip::libzip
    PROPERTIES
      IMPORTED_LOCATION "${INSTALL_DIR}/lib/libzip${CMAKE_STATIC_LIBRARY_SUFFIX}"
      INTERFACE_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include"
  )
  add_dependencies(libzip::libzip libzip-install)

  # Mark package as found.
  set(libzip_FOUND TRUE)
endif()
