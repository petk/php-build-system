#[=============================================================================[
Wrapper for finding the `libzip` library.

Module first tries to find the `libzip` library on the system. If not
successful it tries to download it from the upstream source with `FetchContent`
module and build it together with the PHP build.

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
  libzip
  PROPERTIES
    URL "https://libzip.org/"
    DESCRIPTION "Library for reading and writing ZIP compressed archives"
)

# Minimum required version for the libzip dependency.
set(PHP_libzip_MIN_VERSION 1.7.1)

# Download version when system dependency is not found.
set(PHP_libzip_DOWNLOAD_VERSION 1.11.2)

FetchContent_Declare(
  libzip
  URL https://github.com/nih-at/libzip/releases/download/v${PHP_libzip_DOWNLOAD_VERSION}/libzip-${PHP_libzip_DOWNLOAD_VERSION}.tar.gz
  EXCLUDE_FROM_ALL
  SYSTEM
  FIND_PACKAGE_ARGS
)

find_package(libzip ${PHP_libzip_MIN_VERSION})

if(NOT libzip_FOUND)
  include(Packages/ZLIB)

  set(FETCHCONTENT_QUIET NO)

  # The above EXCLUDE_FROM_ALL was introduced in CMake 3.28.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.28)
    FetchContent_MakeAvailable(libzip)
  else()
    FetchContent_GetProperties(libzip)
    if(NOT libzip_POPULATED)
      FetchContent_Populate(libzip)

      add_subdirectory(
        ${libzip_SOURCE_DIR}
        ${libzip_BINARY_DIR}
        EXCLUDE_FROM_ALL
      )
    endif()
  endif()

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound libzip)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND libzip)
  endblock()

  add_library(libzip::libzip INTERFACE IMPORTED GLOBAL)
  target_link_libraries(libzip::libzip INTERFACE zip)

  # Mark package as found.
  set(libzip_FOUND TRUE)

  # Clean used variables.
  unset(FETCHCONTENT_QUIET)
endif()
