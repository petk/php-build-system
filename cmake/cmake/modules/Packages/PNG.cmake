#[=============================================================================[
Wrapper for finding the `PNG` library.

Module first tries to find the `PNG` library on the system. If not
successful it tries to download it from the upstream source with `FetchContent`
module and build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindPNG.html

The `FetchContent` CMake module does things differently compared to the
`find_package()` flow:
* By default, it uses `QUIET` in its `find_package()` call when calling the
  `FetchContent_MakeAvailable()`;
* When using `FeatureSummary`, dependencies must be moved manually to
  `PACKAGES_FOUND` from the `PACKAGES_NOT_FOUND` global property;

TODO: Improve this. This is for now only initial `FetchContent` integration for
testing purposes and will be changed in the future.
#]=============================================================================]

include(FeatureSummary)
include(FetchContent)

set_package_properties(
  PNG
  PROPERTIES
    URL "http://libpng.org"
    DESCRIPTION "Portable Network Graphics (PNG image format) library"
)

# Minimum required version for the PNG dependency.
#set(PHP_PNG_MIN_VERSION ?.?.??)

# Download version when system dependency is not found.
set(PHP_PNG_DOWNLOAD_VERSION 1.6.44)

FetchContent_Declare(
  PNG
  URL https://download.sourceforge.net/libpng/libpng-${PHP_PNG_DOWNLOAD_VERSION}.tar.gz
  EXCLUDE_FROM_ALL
  SYSTEM
  FIND_PACKAGE_ARGS
)

find_package(PNG ${PHP_PNG_MIN_VERSION})

if(NOT PNG_FOUND)
  include(Packages/ZLIB)

  set(FETCHCONTENT_QUIET NO)

  # The above EXCLUDE_FROM_ALL was introduced in CMake 3.28.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.28)
    FetchContent_MakeAvailable(PNG)
  else()
    FetchContent_GetProperties(PNG)
    if(NOT PNG_POPULATED)
      FetchContent_Populate(PNG)

      add_subdirectory(
        ${PNG_SOURCE_DIR}
        ${PNG_BINARY_DIR}
        EXCLUDE_FROM_ALL
      )
    endif()
  endif()

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound PNG)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND PNG)
  endblock()

  # Mark package as found.
  set(PNG_FOUND TRUE)

  # Clean used variables.
  unset(FETCHCONTENT_QUIET)
endif()
