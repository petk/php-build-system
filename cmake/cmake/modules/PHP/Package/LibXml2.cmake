#[=============================================================================[
# PHP/Package/LibXml2

Finds and downloads the `libxml2` library:

```cmake
include(PHP/Package/LibXml2)
```

This module first tries to find the `libxml2` library on the system. If not
successful it tries to download it from the upstream source with
`ExternalProject` module and build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html

## Examples

Basic usage:

```cmake
# CMakeLists.txt
include(PHP/Package/LibXml2)
target_link_libraries(example PRIVATE LibXml2::LibXml2)
```
#]=============================================================================]

include(FeatureSummary)
include(ExternalProject)

set_package_properties(
  LibXml2
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxml2"
    DESCRIPTION "XML parser and toolkit"
)

# Minimum required version for the libxml2 dependency.
set(PHP_LIBXML2_MIN_VERSION 2.9.0)

# Download version when system dependency is not found.
set(PHP_LIBXML2_DOWNLOAD_VERSION 2.14.4)

if(TARGET LibXml2::LibXml2)
  set(LibXml2_FOUND TRUE)
  get_property(LibXml2_DOWNLOADED GLOBAL PROPERTY _PHP_LibXml2_DOWNLOADED)
  return()
endif()

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})

if(NOT LibXml2_FOUND)
  message(
    STATUS
    "LibXml2 ${PHP_LIBXML2_DOWNLOAD_VERSION} will be downloaded at build phase"
  )

  include(PHP/Package/ZLIB)

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")
  list(APPEND options -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_LZMA=OFF)

  ExternalProject_Add(
    LibXml2
    STEP_TARGETS build install
    URL
      https://github.com/GNOME/libxml2/archive/refs/tags/v${PHP_LIBXML2_DOWNLOAD_VERSION}.tar.gz
    CMAKE_ARGS ${options}
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/libxml2-installation
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libxml2${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(LibXml2 ZLIB::ZLIB)

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "LibXml2")
    get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound ${package})
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${packagesNotFound})
    get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
    list(FIND packagesFound ${package} found)
    if(found EQUAL -1)
      set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${package})
    endif()
  endblock()

  ExternalProject_Get_Property(LibXml2 INSTALL_DIR)

  # Bypass issue with non-existing include directory for the imported target.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(LibXml2::LibXml2 STATIC IMPORTED GLOBAL)
  set_target_properties(
    LibXml2::LibXml2
    PROPERTIES
      IMPORTED_LOCATION "${INSTALL_DIR}/lib/libxml2${CMAKE_STATIC_LIBRARY_SUFFIX}"
      INTERFACE_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include"
  )
  add_dependencies(LibXml2::LibXml2 LibXml2-install)

  # Mark package as found.
  set(LibXml2_FOUND TRUE)

  define_property(
    GLOBAL
    PROPERTY _PHP_LibXml2_DOWNLOADED
    BRIEF_DOCS "Marker that LibXml2 library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_LibXml2_DOWNLOADED TRUE)
  set(LibXml2_DOWNLOADED TRUE)
endif()
