#[=============================================================================[
# PHP/Package/PNG

Finds or downloads the PNG library:

```cmake
include(PHP/Package/PNG)
```

Module first tries to find the `PNG` library on the system. If not
successful it tries to download it from the upstream source and builds it
together with the PHP build.

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
include(FetchContent)

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

macro(php_package_png_find)
  if(TARGET PNG::PNG)
    set(PNG_FOUND TRUE)
    get_property(PNG_DOWNLOADED GLOBAL PROPERTY _PHP_PNG_DOWNLOADED)
  else()
    # PNG depends on ZLIB.
    include(PHP/Package/ZLIB)

    find_package(PNG ${PHP_PNG_MIN_VERSION})

    if(NOT PNG_FOUND)
      _php_package_png_download()
    endif()
  endif()
endmacro()

macro(_php_package_png_download)
  message(STATUS "Downloading PNG ${PHP_PNG_DOWNLOAD_VERSION}")

  FetchContent_Declare(
    PNG
    URL https://download.sourceforge.net/libpng/libpng-${PHP_PNG_DOWNLOAD_VERSION}.tar.gz
    SOURCE_SUBDIR non-existing
    OVERRIDE_FIND_PACKAGE
  )

  FetchContent_MakeAvailable(PNG)

  set(options "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>")

  if(ZLIB_DOWNLOADED)
    ExternalProject_Get_Property(ZLIB INSTALL_DIR)
    list(APPEND options "-DZLIB_ROOT=${INSTALL_DIR}")
  endif()

  list(APPEND options -DPNG_TESTS=OFF)

  ExternalProject_Add(
    PNG
    STEP_TARGETS configure build install
    SOURCE_DIR ${png_SOURCE_DIR}
    BINARY_DIR ${png_BINARY_DIR}
    CMAKE_ARGS ${options}
    INSTALL_DIR ${FETCHCONTENT_BASE_DIR}/png-install
    INSTALL_BYPRODUCTS <INSTALL_DIR>/lib/libpng${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  add_dependencies(PNG-configure ZLIB::ZLIB)

  ExternalProject_Get_Property(PNG INSTALL_DIR)

  # Bypass missing directory error for the imported target below.
  file(MAKE_DIRECTORY ${INSTALL_DIR}/include)

  add_library(PNG::PNG STATIC IMPORTED GLOBAL)
  add_dependencies(PNG::PNG PNG-install)

  set_target_properties(
    PNG::PNG
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${INSTALL_DIR}/include
      IMPORTED_LOCATION ${INSTALL_DIR}/lib/libpng${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "PNG")
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
  set(PNG_FOUND TRUE)

  define_property(
    GLOBAL
    PROPERTY _PHP_PNG_DOWNLOADED
    BRIEF_DOCS "Marker that PNG library will be downloaded"
  )

  set_property(GLOBAL PROPERTY _PHP_PNG_DOWNLOADED TRUE)
  set(PNG_DOWNLOADED TRUE)
endmacro()

php_package_png_find()
