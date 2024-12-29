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

* Default: `OFF`
* Values: `ON|OFF`

Use the GNU Readline library instead of Editline.
#]=============================================================================]

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

cmake_dependent_option(
  PHP_EXT_READLINE_LIBREADLINE
  "Use the GNU Readline library instead of Editline"
  OFF
  "PHP_EXT_READLINE"
  OFF
)
mark_as_advanced(PHP_EXT_READLINE_LIBREADLINE)

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

if(NOT PHP_EXT_READLINE_LIBREADLINE)
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
else()
  message(
    WARNING
    "The GNU Readline library is licensed under the GNU GPL 3, which is not "
    "compatible with the PHP license. The recommended library for using and "
    "distributing the PHP 'readline' extension without limitations is libedit. "
    "To build with libedit, remove the 'PHP_EXT_READLINE_LIBREADLINE', or set "
    "it to 'OFF'."
  )
  find_package(Readline)
  set_package_properties(
    Readline
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the readline extension."
  )

  target_link_libraries(php_ext_readline PUBLIC Readline::Readline)

  if(TARGET Readline::Readline)
    # Sanity minimum version check if Readline library has the
    # 'rl_pending_input' variable. The macOS systems might have an outdated
    # forked Readline library installed on the system by default, which doesn't
    # have this variable.
    # See https://bugs.php.net/48608.
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Readline::Readline)

      check_symbol_exists(
        rl_pending_input
        # The <readline/readline.h> is not self-contained header and some
        # systems, like macOS, need <stdio.h> to have FILE type available.
        "stdio.h;readline/readline.h"
        _readline_have_rl_pending_input
      )
    cmake_pop_check_state()

    if(NOT _readline_have_rl_pending_input)
      message(
        FATAL_ERROR
        "Readline library check failed. Variable rl_pending_input missing. "
        "This version of Readline installation is not supported. Try using "
        "libedit instead (set 'PHP_EXT_READLINE_LIBREADLINE' to 'OFF')."
      )
    endif()

    check_library_exists(
      Readline::Readline
      rl_callback_read_char
      ""
      HAVE_RL_CALLBACK_READ_CHAR
    )
    check_library_exists(
      Readline::Readline
      rl_on_new_line
      ""
      HAVE_RL_ON_NEW_LINE
    )
    check_library_exists(
      Readline::Readline
      rl_completion_matches
      ""
      HAVE_RL_COMPLETION_MATCHES
    )
  endif()

  set(HAVE_HISTORY_LIST TRUE)
  set(HAVE_LIBREADLINE TRUE)
endif()

configure_file(cmake/config.h.in config.h)

# TODO: Editline/Readline dependent libraries shouldn't be linked on this level.
# Recheck if this is really needed. Either move to find modules or remove it.
# Also, for example, Editline with Autoconf integration has even more thorough
# dependencies checked in current version.

#[[
set(CURSES_NEED_NCURSES TRUE)
find_package(Curses)
set_package_properties(
  Curses
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the readline extension."
)

# The CMake's Curses find module, doesn't define IMPORTED target yet.
if(CURSES_FOUND AND NOT TARGET Curses::Curses)
  add_library(Curses::Curses INTERFACE IMPORTED)

  set_target_properties(
    Curses::Curses
    PROPERTIES
      INTERFACE_LINK_LIBRARIES "${CURSES_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${CURSES_INCLUDE_DIRS}"
      INTERFACE_COMPILE_OPTIONS "${CURSES_CFLAGS}"
  )
endif()

target_link_libraries(php_ext_readline PRIVATE Curses::Curses)

# TODO: Check for the obsolescent termcap library more properly.
if(NOT CURSES_FOUND)
  check_library_exists(termcap, tgetent "" _have_termcap_library)

  if(_have_termcap_library)
    target_link_libraries(php_ext_readline PRIVATE termcap)
  endif()
endif()
]]#
