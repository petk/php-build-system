# TODO: ext/readline is cli extension only.
include(CheckCompilerFlag)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_READLINE "Enable the readline extension" OFF)

add_feature_info(
  "ext/readline"
  EXT_READLINE
  "Interface for using Editline library. CLI/CGI only"
)

cmake_dependent_option(
  EXT_READLINE_SHARED
  "Build the readline extension as a shared library"
  OFF
  "EXT_READLINE;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_READLINE_LIBREADLINE
  "Use the GNU Readline library instead of Editline"
  OFF
  "EXT_READLINE"
  OFF
)

add_feature_info(
  "ext/readline with GNU Readline"
  EXT_READLINE_LIBREADLINE
  "GNU Readline library support instead of Editline"
)

if(NOT EXT_READLINE)
  return()
endif()

if(EXT_READLINE_SHARED)
  add_library(php_readline SHARED)
else()
  add_library(php_readline)
endif()

target_sources(
  php_readline
  PRIVATE
    readline_cli.c
    readline.c
)

# Add -Wno-strict-prototypes as depends on user libs.
check_compiler_flag(C -Wno-strict-prototypes HAVE_WNO_STRICT_PROTOTYPES_C)
if(HAVE_WNO_STRICT_PROTOTYPES_C)
  target_compile_options(
    php_readline
    PRIVATE
      $<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>
  )
endif()

if(NOT EXT_READLINE_LIBREADLINE)
  find_package(Editline)
  set_package_properties(
    Editline
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the readline extension."
  )

  target_link_libraries(php_readline PUBLIC Editline::Editline)

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

  set(
    HAVE_LIBEDIT 1
    CACHE INTERNAL "Whether Editline is used for readline extension"
  )
else()
  find_package(Readline)
  set_package_properties(
    Readline
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the readline extension."
  )

  target_link_libraries(php_readline PUBLIC Readline::Readline)

  if(TARGET Readline::Readline)
    # Sanity minimum version check if Readline library has the
    # 'rl_pending_input' variable. There was once an outdated Readline library
    # installed on old obsolete macOS. See https://bugs.php.net/48608.
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
        "libedit instead (set EXT_READLINE_LIBREADLINE to 'OFF')."
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

  set(
    HAVE_HISTORY_LIST 1
    CACHE INTERNAL "Whether Readline library has history_list"
  )
  set(
    HAVE_LIBREADLINE 1
    CACHE INTERNAL "Whether Readline is used for readline extension"
  )
endif()

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

target_link_libraries(php_readline PRIVATE Curses::Curses)

# TODO: Check for the obsolescent termcap library more properly.
if(NOT CURSES_FOUND)
  check_library_exists(termcap, tgetent "" _have_termcap_library)

  if(_have_termcap_library)
    target_link_libraries(php_readline PRIVATE termcap)
  endif()
endif()
]]#
