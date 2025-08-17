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
php_package_oniguruma()
target_link_libraries(php_ext_foo PRIVATE Oniguruma::Oniguruma)
```
#]=============================================================================]

include(ExternalProject)
include(FeatureSummary)
include(FetchContent)
include(PHP/Package/_Internal)

# Minimum required version for the Oniguruma dependency.
set(PHP_ONIGURUMA_MIN_VERSION 5.9.6) # This is the 1st tag available on GitHub.

# Download version when system dependency is not found.
set(PHP_ONIGURUMA_DOWNLOAD_VERSION 6.9.10)

set(
  PHP_ONIGURUMA_URL
  https://github.com/petk/oniguruma/archive/refs/tags/v${PHP_ONIGURUMA_DOWNLOAD_VERSION}.tar.gz
)

macro(php_package_oniguruma)
  if(PHP_DOWNLOAD_FORCE)
    set(args OVERRIDE_FIND_PACKAGE)
  else()
    set(args FIND_PACKAGE_ARGS ${PHP_ONIGURUMA_MIN_VERSION})
  endif()

  FetchContent_Declare(
    Oniguruma
    URL ${PHP_ONIGURUMA_URL}
    SOURCE_SUBDIR non-existing
    ${args}
  )

  find_package(Oniguruma ${PHP_ONIGURUMA_MIN_VERSION})

  if(PHP_USE_FETCHCONTENT)
    if(NOT Oniguruma_FOUND)
      message(STATUS "Downloading ${PHP_ONIGURUMA_URL}")
    endif()

    FetchContent_MakeAvailable(Oniguruma)

    if(NOT Oniguruma_FOUND)
      _php_package_oniguruma_init()
    endif()
  endif()

  get_property(PHP_ONIGURUMA_DOWNLOADED GLOBAL PROPERTY _PHP_ONIGURUMA_DOWNLOADED)

  if(PHP_ONIGURUMA_DOWNLOADED)
    set(PHP_ONIG_KOI8 FALSE)
    set(Oniguruma_VERSION ${PHP_ONIGURUMA_DOWNLOAD_VERSION})
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

  php_package_mark_as_found(Oniguruma)

  define_property(
    GLOBAL
    PROPERTY _PHP_ONIGURUMA_DOWNLOADED
    BRIEF_DOCS "Marker that Oniguruma library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_ONIGURUMA_DOWNLOADED TRUE)
endmacro()

php_package_oniguruma()
