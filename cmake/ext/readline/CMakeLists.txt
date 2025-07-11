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
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

project(
  PhpExtensionReadline
  LANGUAGES C
)

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
  PHP_EXT_READLINE
  OFF
)

if(NOT PHP_EXT_READLINE)
  return()
endif()

if(PHP_EXT_READLINE_SHARED)
  add_library(php_ext_readline MODULE)
else()
  add_library(php_ext_readline OBJECT)
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
php_check_compiler_flag(C -Wno-strict-prototypes PHP_HAS_WNO_STRICT_PROTOTYPES)
if(PHP_HAS_WNO_STRICT_PROTOTYPES)
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
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Editline::Editline)

    check_symbol_exists(
      rl_callback_read_char
      editline/readline.h
      HAVE_RL_CALLBACK_READ_CHAR
    )

    check_symbol_exists(
      rl_on_new_line
      editline/readline.h
      HAVE_RL_ON_NEW_LINE
    )

    check_symbol_exists(
      rl_completion_matches
      editline/readline.h
      HAVE_RL_COMPLETION_MATCHES
    )

    check_symbol_exists(
      history_list
      editline/readline.h
      HAVE_HISTORY_LIST
    )

    check_symbol_exists(
      rl_erase_empty_line
      editline/readline.h
      HAVE_ERASE_EMPTY_LINE
    )
  cmake_pop_check_state()
endif()

set(HAVE_LIBEDIT TRUE)

configure_file(cmake/config.h.in config.h)
