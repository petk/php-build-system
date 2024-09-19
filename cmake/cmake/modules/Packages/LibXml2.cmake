#[=============================================================================[
Wrapper for finding the `libxml2` library.

Module first tries to find the `libxml2` library on the system. If not
successful it tries to download it from the upstream source with `FetchContent`
module and build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html

The `FetchContent` CMake module does things differently compared to the
`find_package()` flow:
* By default it uses `QUIET` in its `find_package()` call when calling the
  `FetchContent_MakeAvailable()`;
* When using `FeatureSummary`, dependencies must be moved manually to
  `PACKAGES_FOUND` from the `PACKAGES_NOT_FOUND` global property;

TODO: Improve this. This is for now only initial `FetchContent` integration for
testing purposes and will be changed in the future.
#]=============================================================================]

include(FeatureSummary)
include(FetchContent)

set_package_properties(
  LibXml2
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxml2"
    DESCRIPTION "XML parser and toolkit"
)

# Minimum required version for the libxml2 dependency.
set(PHP_LIBXML2_MIN_VERSION 2.9.0)

# Download version when system dependency is not found.
set(PHP_LIBXML2_DOWNLOAD_VERSION 2.12.7)

FetchContent_Declare(
  LibXml2
  URL https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${PHP_LIBXML2_DOWNLOAD_VERSION}/libxml2-v${PHP_LIBXML2_DOWNLOAD_VERSION}.tar.gz
  EXCLUDE_FROM_ALL
  SYSTEM
  FIND_PACKAGE_ARGS
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})

if(NOT LibXml2_FOUND)
  set(FETCHCONTENT_QUIET NO)
  set(LIBXML2_WITH_PYTHON OFF)
  set(LIBXML2_WITH_LZMA OFF)

  # The above EXCLUDE_FROM_ALL was introduced in CMake 3.28.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.28)
    FetchContent_MakeAvailable(LibXml2)
  else()
    FetchContent_GetProperties(LibXml2)
    if(NOT LibXml2_POPULATED)
      FetchContent_Populate(LibXml2)

      add_subdirectory(
        ${libxml2_SOURCE_DIR}
        ${libxml2_BINARY_DIR}
        EXCLUDE_FROM_ALL
      )
    endif()
  endif()

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound LibXml2)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND LibXml2)
  endblock()

  # Mark package as found.
  set(LibXml2_FOUND TRUE)

  # Clean used variables.
  unset(FETCHCONTENT_QUIET)
  unset(LIBXML2_WITH_PYTHON)
  unset(LIBXML2_WITH_LZMA)
endif()
