#[=============================================================================[
# The gettext extension

This extension provides support for GNU gettext using NLS (Native Language
Support) API.

## Configuration options

### PHP_EXT_GETTEXT

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_GETTEXT_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_GETTEXT
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
  PHP_EXT_GETTEXT
  OFF
)

if(NOT PHP_EXT_GETTEXT)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(gettext)

if(PHP_EXT_GETTEXT_SHARED)
  add_library(php_ext_gettext MODULE)
else()
  add_library(php_ext_gettext OBJECT)
endif()

target_sources(
  php_ext_gettext
  PRIVATE
    gettext.c
    gettext.stub.php
)

target_include_directories(
  php_ext_gettext
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}
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

    check_symbol_exists(
      bind_textdomain_codeset
      libintl.h
      PHP_EXT_GETTEXT_HAVE_BIND_TEXTDOMAIN_CODESET
    )
    set(
      HAVE_BIND_TEXTDOMAIN_CODESET
      ${PHP_EXT_GETTEXT_HAVE_BIND_TEXTDOMAIN_CODESET}
    )

    check_symbol_exists(
      dcngettext
      libintl.h
      PHP_EXT_GETTEXT_HAVE_DCNGETTEXT
    )
    set(HAVE_DCNGETTEXT ${PHP_EXT_GETTEXT_HAVE_DCNGETTEXT})

    check_symbol_exists(
      dngettext
      libintl.h
      PHP_EXT_GETTEXT_HAVE_DNGETTEXT
    )
    set(HAVE_DNGETTEXT ${PHP_EXT_GETTEXT_HAVE_DNGETTEXT})

    check_symbol_exists(
      ngettext
      libintl.h
      PHP_EXT_GETTEXT_HAVE_NGETTEXT
    )
    set(HAVE_NGETTEXT ${PHP_EXT_GETTEXT_HAVE_NGETTEXT})
  cmake_pop_check_state()

  # Create a symbolic link when intl is built into musl C library. The gettext
  # functions there ignore the codeset suffix on directories like 'en_US.UTF-8';
  # instead they look only in 'en_US'.
  include(PHP/StandardLibrary)
  if(
    PHP_TESTING
    AND Intl_IS_BUILT_IN
    AND PHP_C_STANDARD_LIBRARY STREQUAL "musl"
  )
    add_test(
      NAME PhpExtGettextAddSymlink
      COMMAND
        ${CMAKE_COMMAND}
        -E
        create_symlink
        en_US.UTF-8
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/locale/en_US
    )
    set_tests_properties(
      PhpExtGettextAddSymlink
      PROPERTIES
        FIXTURES_SETUP PhpExtGettextFixtures
    )

    add_test(
      NAME PhpExtGettextRemoveSymlink
      COMMAND
        ${CMAKE_COMMAND}
        -E
        remove
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/locale/en_US
    )
    set_tests_properties(
      PhpExtGettextRemoveSymlink
      PROPERTIES
        FIXTURES_CLEANUP PhpExtGettextFixtures
    )

    if(PHP_SOURCE_DIR)
      set(dir "${PHP_SOURCE_DIR}")
    else()
      set(dir "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    set_property(
      TEST PhpRunTests
      DIRECTORY ${dir}
      APPEND
      PROPERTY
      FIXTURES_REQUIRED PhpExtGettextFixtures
    )
  endif()
endif()

configure_file(cmake/config.h.in config.h)
