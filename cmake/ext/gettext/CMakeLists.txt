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

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionGettext
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
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
  set(HAVE_LIBINTL TRUE)

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Intl::Intl)

    # Sanity check.
    check_symbol_exists(bindtextdomain libintl.h PHP_EXT_GETTEXT_SANITY_CHECK)
    if(NOT PHP_EXT_GETTEXT_SANITY_CHECK)
      message(
        FATAL_ERROR
        "The ext/gettext sanity check for intl library failed: The "
        "bindtextdomain() could not be found."
      )
    endif()

    check_symbol_exists(bind_textdomain_codeset libintl.h HAVE_BIND_TEXTDOMAIN_CODESET)
    check_symbol_exists(dcngettext libintl.h HAVE_DCNGETTEXT)
    check_symbol_exists(dngettext libintl.h HAVE_DNGETTEXT)
    check_symbol_exists(ngettext libintl.h HAVE_NGETTEXT)
  cmake_pop_check_state()

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
