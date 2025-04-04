#[=============================================================================[
# The readline extension

Configure the `readline` extension.

This extension provides interface for using Editline library.

> [!IMPORTANT]
> This extension should be used only with CLI-based PHP SAPIs.

## PHP_EXT_READLINE

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_READLINE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_READLINE_LIBREADLINE

:red_circle: *Removed as of PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Use the GNU Readline library instead of Editline.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionReadline
  LANGUAGES C
)

include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(PHP_EXT_READLINE "Enable the readline extension (only for CLI-based SAPIs)")

add_feature_info(
  "ext/readline"
  PHP_EXT_READLINE
  "editable command lines support"
)

cmake_dependent_option(
  PHP_EXT_READLINE_SHARED
  "Build the readline extension as a shared library"
  OFF
  "PHP_EXT_READLINE;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_READLINE)
  return()
endif()

if(PHP_EXT_READLINE_SHARED)
  add_library(php_ext_readline SHARED)
else()
  add_library(php_ext_readline)
endif()

set_target_properties(php_ext_readline PROPERTIES PHP_CLI TRUE)

target_sources(
  php_ext_readline
  PRIVATE
    readline_cli.c
    readline.c
    readline.stub.php
)

# Add -Wno-strict-prototypes as depends on user libs.
php_check_compiler_flag(C -Wno-strict-prototypes HAVE_WNO_STRICT_PROTOTYPES_C)
if(HAVE_WNO_STRICT_PROTOTYPES_C)
  target_compile_options(
    php_ext_readline
    PRIVATE
      $<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>
  )
endif()

find_package(Editline)
set_package_properties(
  Editline
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the readline extension."
)

target_link_libraries(php_ext_readline PUBLIC Editline::Editline)

if(TARGET Editline::Editline)
  check_library_exists(
    Editline::Editline
    rl_callback_read_char
    ""
    HAVE_RL_CALLBACK_READ_CHAR
  )
  check_library_exists(
    Editline::Editline
    rl_on_new_line
    ""
    HAVE_RL_ON_NEW_LINE
  )
  check_library_exists(
    Editline::Editline
    rl_completion_matches
    ""
    HAVE_RL_COMPLETION_MATCHES
  )
  check_library_exists(
    Editline::Editline
    history_list
    ""
    HAVE_HISTORY_LIST
  )
endif()

set(HAVE_LIBEDIT TRUE)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES Editline::Editline)
  check_symbol_exists(
    rl_erase_empty_line
    editline/readline.h
    HAVE_ERASE_EMPTY_LINE
  )
cmake_pop_check_state()

configure_file(cmake/config.h.in config.h)
