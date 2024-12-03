#[=============================================================================[
Wrapper for finding the `ZLIB` library.

Module first tries to find the `ZLIB` library on the system. If not successful
it tries to download it from the upstream source with `FetchContent` module and
build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindZLIB.html

The `FetchContent` CMake module does things differently compared to the
`find_package()` flow:
* By default, it uses `QUIET` in its `find_package()` call when calling the
  `FetchContent_MakeAvailable()`
* When using `FeatureSummary`, dependencies must be moved manually to
  `PACKAGES_FOUND` from the `PACKAGES_NOT_FOUND` global property

TODO: Improve this. This is for now only initial `FetchContent` integration for
testing purposes and will be changed in the future.
#]=============================================================================]

include(FeatureSummary)
include(FetchContent)

set_package_properties(
  ZLIB
  PROPERTIES
    URL "https://zlib.net/"
    DESCRIPTION "Compression library"
)

# Minimum required version for the zlib dependency.
set(PHP_ZLIB_MIN_VERSION 1.2.0.4)

# Download version when system dependency is not found.
set(PHP_ZLIB_DOWNLOAD_VERSION 1.3.1)

FetchContent_Declare(
  ZLIB
  URL https://github.com/madler/zlib/releases/download/v${PHP_ZLIB_DOWNLOAD_VERSION}/zlib-${PHP_ZLIB_DOWNLOAD_VERSION}.tar.gz
  EXCLUDE_FROM_ALL
  SYSTEM
  FIND_PACKAGE_ARGS
)

find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})

if(NOT ZLIB_FOUND)
  set(FETCHCONTENT_QUIET NO)

  # The above EXCLUDE_FROM_ALL was introduced in CMake 3.28.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.28)
    FetchContent_MakeAvailable(ZLIB)
  else()
    FetchContent_GetProperties(ZLIB)
    if(NOT ZLIB_POPULATED)
      FetchContent_Populate(ZLIB)

      add_subdirectory(
        ${zlib_SOURCE_DIR}
        ${zlib_BINARY_DIR}
        EXCLUDE_FROM_ALL
      )
    endif()
  endif()

  # Move dependency to PACKAGES_FOUND.
  block()
    get_cmake_property(packagesNotFound PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packagesNotFound ZLIB)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND packagesNotFound)
    get_cmake_property(packagesFound PACKAGES_FOUND)
    set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ZLIB)
  endblock()

  set_target_properties(zlibstatic PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
  add_library(ZLIB::ZLIB INTERFACE IMPORTED GLOBAL)
  target_link_libraries(ZLIB::ZLIB INTERFACE zlibstatic)
  target_include_directories(
    zlibstatic
    PUBLIC
      $<BUILD_INTERFACE:${zlib_BINARY_DIR}>
      $<INSTALL_INTERFACE:include>
  )

  # Mark package as found.
  set(ZLIB_FOUND TRUE)

  # Clean used variables.
  unset(FETCHCONTENT_QUIET)
endif()
