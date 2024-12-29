#[=============================================================================[
# The gettext extension

Configure the `gettext` extension.

This extension provides support for GNU gettext using NLS (Native Language
Support) API.

## PHP_EXT_GETTEXT

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_GETTEXT_SHARED

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

option(PHP_EXT_GETTEXT "Enable the gettext extension")

add_feature_info(
  "ext/gettext"
  PHP_EXT_GETTEXT
  "GNU gettext support using NLS (Native Language Support) API"
)

cmake_dependent_option(
  PHP_EXT_GETTEXT_SHARED
  "Build the gettext extension as a shared library"
  OFF
  "PHP_EXT_GETTEXT;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_GETTEXT)
  return()
endif()

if(PHP_EXT_GETTEXT_SHARED)
  add_library(php_ext_gettext SHARED)
else()
  add_library(php_ext_gettext)
endif()

target_sources(
  php_ext_gettext
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

target_link_libraries(php_ext_gettext PRIVATE Intl::Intl)

if(TARGET Intl::Intl)
  # Sanity check.
  check_library_exists(Intl::Intl bindtextdomain "" _HAVE_BINDTEXTDOMAIN)

  if(NOT _HAVE_BINDTEXTDOMAIN)
    message(FATAL_ERROR "Unable to find the required gettext library.")
  endif()

  set(HAVE_LIBINTL TRUE)

  check_library_exists(Intl::Intl ngettext "" HAVE_NGETTEXT)
  check_library_exists(Intl::Intl dngettext "" HAVE_DNGETTEXT)
  check_library_exists(Intl::Intl dcngettext "" HAVE_DCNGETTEXT)
  check_library_exists(Intl::Intl bind_textdomain_codeset "" HAVE_BIND_TEXTDOMAIN_CODESET)

  # Create a symbolic link when intl is built into musl C library. The gettext
  # functions there ignore the codeset suffix on directories like 'en_US.UTF-8';
  # instead they look only in 'en_US'.
  if(Intl_IS_BUILT_IN AND PHP_C_STANDARD_LIBRARY STREQUAL "musl")
    message(STATUS "Patching tests: symlinking en_US.UTF-8 messages")
    file(
      CREATE_LINK
      en_US.UTF-8
      ${CMAKE_CURRENT_SOURCE_DIR}/tests/locale/en_US
      SYMBOLIC
    )
  endif()
endif()

configure_file(cmake/config.h.in config.h)
