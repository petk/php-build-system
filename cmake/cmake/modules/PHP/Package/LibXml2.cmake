#[=============================================================================[
PHP/Package/LibXml2

Wrapper for finding the libxml2 library.

Module first tries to find the libxml2 library on the system. If not successful
it tries to download it from the upstream source with FetchContent module and
build it together with the PHP build.

See: https://cmake.org/cmake/help/latest/module/FindLibXml2.html

The FetchContent CMake module does things differently compared to the
find_package() workflow:
* By default, it uses the QUIET in its find_package() call when calling the
  FetchContent_MakeAvailable();
* When using the FeatureSummary module, dependencies must be moved manually to
  PACKAGES_FOUND from the PACKAGES_NOT_FOUND global property;
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
set(PHP_PACKAGE_LIBXML2_MIN_VERSION 2.9.4)

# Download version when system dependency is not found.
set(PHP_PACKAGE_LIBXML2_DOWNLOAD_VERSION 2.14.4)

FetchContent_Declare(
  LibXml2
  URL https://github.com/GNOME/libxml2/archive/refs/tags/v${PHP_PACKAGE_LIBXML2_DOWNLOAD_VERSION}.tar.gz
  EXCLUDE_FROM_ALL
  SYSTEM
  FIND_PACKAGE_ARGS
)

find_package(LibXml2 ${PHP_PACKAGE_LIBXML2_MIN_VERSION})

if(NOT LibXml2_FOUND)
  set(FETCHCONTENT_QUIET NO)
  set(LIBXML2_WITH_PYTHON OFF)
  set(LIBXML2_WITH_LZMA OFF)

  FetchContent_MakeAvailable(LibXml2)

  # Move dependency to PACKAGES_FOUND.
  block()
    set(package "LibXml2")
    get_property(packages_not_found GLOBAL PROPERTY PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM packages_not_found ${package})
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${packages_not_found})
    get_property(packages_found GLOBAL PROPERTY PACKAGES_FOUND)
    list(FIND packages_found ${package} found)
    if(found EQUAL -1)
      set_property(GLOBAL APPEND PROPERTY PACKAGES_FOUND ${package})
    endif()
  endblock()

  # Mark package as found.
  set(LibXml2_FOUND TRUE)

  # Clean used variables.
  unset(FETCHCONTENT_QUIET)
  unset(LIBXML2_WITH_PYTHON)
  unset(LIBXML2_WITH_LZMA)
endif()
