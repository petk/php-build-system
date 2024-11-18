#[=============================================================================[
# PHP/Package/Oniguruma

Finds or downloads the Oniguruma library:

```cmake
include(PHP/Package/Oniguruma)
```

This module first tries to find the Oniguruma library on the system. If not
found it downloads it from the upstream source during the main project
configuration phase and then configures and builds it during the main project's
build phase.

The `FetchContent` module is used, which provides integration with other
dependency providers, such as Conan.

## Examples

Basic usage:

```cmake
include(PHP/Package/Oniguruma)
target_link_libraries(php_ext_foo PRIVATE Oniguruma::Oniguruma)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)

# Minimum required version for the Oniguruma dependency.
set(PHP_ONIGURUMA_MIN_VERSION 5.9.6) # This is the 1st tag available on GitHub.

# Download version when system dependency is not found.
set(PHP_ONIGURUMA_DOWNLOAD_VERSION 6.9.10)

macro(php_package_oniguruma)
  FetchContent_Declare(
    Oniguruma
    URL https://github.com/petk/oniguruma/archive/refs/tags/v${PHP_ONIGURUMA_DOWNLOAD_VERSION}.tar.gz
    SOURCE_SUBDIR non-existing
    FIND_PACKAGE_ARGS ${PHP_ONIGURUMA_MIN_VERSION}
  )

  #find_package(Oniguruma ${PHP_ONIGURUMA_MIN_VERSION})

  FetchContent_MakeAvailable(Oniguruma)

  if(NOT Oniguruma_FOUND)
    _php_package_oniguruma_init()
  endif()
endmacro()

macro(_php_package_oniguruma_init)
  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  list(
    APPEND
    options
      -DINSTALL_DOCUMENTATION=OFF
      -DBUILD_TEST=OFF
      -DBUILD_SHARED_LIBS=OFF
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  )

  ExternalProject_Add(
    Oniguruma
    STEP_TARGETS build install
    SOURCE_DIR ${oniguruma_SOURCE_DIR}
    BINARY_DIR ${oniguruma_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/oniguruma-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libonig${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  ExternalProject_Get_Property(Oniguruma INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(Oniguruma::Oniguruma STATIC IMPORTED GLOBAL)
  add_dependencies(Oniguruma::Oniguruma Oniguruma-install)
  set_target_properties(
    Oniguruma::Oniguruma
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libonig${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "Oniguruma")
    get_property(packagesNotFound GLOBAL PROPERTY PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound ${package})
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${packagesNotFound})
    get_property(packagesFound GLOBAL PROPERTY PACKAGES_FOUND)
    list(FIND packagesFound ${package} found)
    if(found EQUAL -1)
      set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${package})
    endif()
  endblock()

  define_property(
    GLOBAL
    PROPERTY _PHP_Oniguruma_DOWNLOADED
    BRIEF_DOCS "Marker that Oniguruma library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_Oniguruma_DOWNLOADED TRUE)
  set(Oniguruma_DOWNLOADED TRUE)

  set(PHP_ONIG_KOI8 FALSE)
endmacro()

php_package_oniguruma()

macro(php_package_oniguruma_find)
  if(TARGET Oniguruma::Oniguruma)
    get_property(Oniguruma_DOWNLOADED GLOBAL PROPERTY _PHP_Oniguruma_DOWNLOADED)
    set(PHP_ONIG_KOI8 FALSE)
  else()
    find_package(Oniguruma ${PHP_ONIGURUMA_MIN_VERSION})

    if(NOT Oniguruma_FOUND)
      _php_package_oniguruma_download()
    endif()
  endif()
endmacro()

macro(_php_package_oniguruma_download)
  message(STATUS "Downloading Oniguruma ${PHP_ONIGURUMA_DOWNLOAD_VERSION}")
endmacro()
