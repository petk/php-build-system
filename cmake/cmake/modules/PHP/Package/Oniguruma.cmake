#[=============================================================================[
# PHP/Package/Oniguruma

Finds or downloads the Oniguruma library:

```cmake
include(PHP/Package/Oniguruma)
```

Wrapper for finding the `Oniguruma` library.

Module first tries to find the `Oniguruma` library on the system. If not
successful it tries to download it from the upstream source with
`ExternalProject` module and build it together with the PHP build.

## Examples

Basic usage:

```cmake
include(PHP/Package/Oniguruma)
target_link_libraries(php_ext_foo PRIVATE Oniguruma::Oniguruma)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)

# Minimum required version for the Oniguruma dependency.
#set(PHP_ONIGURUMA_MIN_VERSION ?.?.??)

# Download version when system dependency is not found.
set(PHP_ONIGURUMA_DOWNLOAD_VERSION 6.9.10)

if(TARGET Oniguruma::Oniguruma)
  set(Oniguruma_FOUND TRUE)
  get_property(Oniguruma_DOWNLOADED GLOBAL PROPERTY _PHP_Oniguruma_DOWNLOADED)
  set(PHP_ONIG_KOI8 FALSE)
  return()
endif()

find_package(Oniguruma ${PHP_ONIGURUMA_MIN_VERSION})

if(NOT Oniguruma_FOUND)
  message(
    STATUS
    "Oniguruma ${PHP_ONIGURUMA_DOWNLOAD_VERSION} will be downloaded at build phase"
  )

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  list(
    APPEND
    options
    -DINSTALL_DOCUMENTATION=OFF
    -DBUILD_TEST=OFF
    -DBUILD_SHARED_LIBS=OFF
  )

  ExternalProject_Add(
    Oniguruma
    STEP_TARGETS build install
    URL
      https://github.com/petk/oniguruma/archive/refs/tags/v${PHP_ONIGURUMA_DOWNLOAD_VERSION}.tar.gz
    CMAKE_ARGS ${options}
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/oniguruma-installation
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libonig${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound Oniguruma)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND Oniguruma)
  endblock()

  ExternalProject_Get_Property(Oniguruma INSTALL_DIR)

  # Bypass issue with non-existing include directory for the imported target.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(Oniguruma::Oniguruma STATIC IMPORTED GLOBAL)
  set_target_properties(
    Oniguruma::Oniguruma
    PROPERTIES
      IMPORTED_LOCATION "${INSTALL_DIR}/lib/libonig${CMAKE_STATIC_LIBRARY_SUFFIX}"
      INTERFACE_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include"
  )
  add_dependencies(Oniguruma::Oniguruma Oniguruma-install)

  # Mark package as found.
  set(Oniguruma_FOUND TRUE)

  define_property(
    GLOBAL
    PROPERTY _PHP_Oniguruma_DOWNLOADED
    BRIEF_DOCS "Marker that Oniguruma library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_Oniguruma_DOWNLOADED TRUE)
  set(Oniguruma_DOWNLOADED TRUE)

  set(PHP_ONIG_KOI8 FALSE)
endif()
