#[=============================================================================[
# PHP/Package/PNG

Finds or downloads the PNG library:

```cmake
include(PHP/Package/PNG)
```

Wrapper for finding the `PNG` library.

Module first tries to find the `PNG` library on the system. If not
successful it tries to download it from the upstream source with
`ExternalProject` module and build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindPNG.html

## Examples

Basic usage:

```cmake
include(PHP/Package/PNG)
target_link_libraries(php_ext_foo PRIVATE PNG::PNG)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)

set_package_properties(
  PNG
  PROPERTIES
    URL "http://libpng.org"
    DESCRIPTION "Portable Network Graphics (PNG image format) library"
)

# Minimum required version for the PNG dependency.
set(PHP_PNG_MIN_VERSION 0.96) # for png_get_IHDR

# Download version when system dependency is not found.
set(PHP_PNG_DOWNLOAD_VERSION 1.6.50)

find_package(PNG ${PHP_PNG_MIN_VERSION})

if(NOT PNG_FOUND)
  message(
    STATUS
    "PNG ${PHP_PNG_DOWNLOAD_VERSION} will be downloaded at build phase"
  )

  include(PHP/Package/ZLIB)

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  if(ZLIB_DOWNLOADED)
    ExternalProject_Get_Property(ZLIB INSTALL_DIR)
    list(APPEND options "-DCMAKE_PREFIX_PATH=${INSTALL_DIR}")
  endif()

  list(APPEND options -DPNG_TESTS=OFF)

  ExternalProject_Add(
    PNG
    STEP_TARGETS build install
    URL
      https://download.sourceforge.net/libpng/libpng-${PHP_PNG_DOWNLOAD_VERSION}.tar.gz
    CMAKE_ARGS ${options}
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/png-installation
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libpng${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(PNG ZLIB::ZLIB)

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound PNG)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND PNG)
  endblock()

  ExternalProject_Get_Property(PNG INSTALL_DIR)

  # Bypass issue with non-existing include directory for the imported target.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(PNG::PNG STATIC IMPORTED GLOBAL)
  set_target_properties(
    PNG::PNG
    PROPERTIES
      IMPORTED_LOCATION "${INSTALL_DIR}/lib/libpng${CMAKE_STATIC_LIBRARY_SUFFIX}"
      INTERFACE_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include"
  )
  add_dependencies(PNG::PNG PNG-install)

  # Mark package as found.
  set(PNG_FOUND TRUE)
endif()
