#[=============================================================================[
# The gettext extension

Configure the `gettext` extension.

## EXT_GETTEXT

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_GETTEXT_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionGettext
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_GETTEXT "Enable the gettext extension" OFF)

add_feature_info(
  "ext/gettext"
  EXT_GETTEXT
  "Support for GNU gettext using NLS (Native Language Support) API"
)

cmake_dependent_option(
  EXT_GETTEXT_SHARED
  "Build the gettext extension as a shared library"
  OFF
  "EXT_GETTEXT;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_GETTEXT)
  return()
endif()

if(EXT_GETTEXT_SHARED)
  add_library(php_gettext SHARED)
else()
  add_library(php_gettext)
endif()

target_sources(
  php_gettext
  PRIVATE
    gettext.c
    gettext.stub.php
)

find_package(Intl)
set_package_properties(
  Intl
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gettext extension."
)

target_link_libraries(php_gettext PRIVATE Intl::Intl)

if(TARGET Intl::Intl)
  # Sanity check.
  check_library_exists(Intl::Intl bindtextdomain "" _HAVE_BINDTEXTDOMAIN)

  if(NOT _HAVE_BINDTEXTDOMAIN)
    message(
      FATAL_ERROR
      "Unable to find required gettext library. Please check the logs."
    )
  endif()

  set(HAVE_LIBINTL 1)

  check_library_exists(Intl::Intl ngettext "" HAVE_NGETTEXT)
  check_library_exists(Intl::Intl dngettext "" HAVE_DNGETTEXT)
  check_library_exists(Intl::Intl dcngettext "" HAVE_DCNGETTEXT)
  check_library_exists(Intl::Intl bind_textdomain_codeset "" HAVE_BIND_TEXTDOMAIN_CODESET)
endif()

configure_file(config.cmake.h.in config.h)
