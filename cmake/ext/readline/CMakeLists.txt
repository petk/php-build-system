include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_READLINE "Whether to enable the readline extension" OFF)

cmake_dependent_option(EXT_READLINE_SHARED "Whether to build the readline extension as shared object" OFF "EXT_READLINE;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_READLINE_LIBREADLINE "Whether to use the GNU readline library instead of libedit" OFF "EXT_READLINE" OFF)

if(NOT EXT_READLINE)
  return()
endif()

if(EXT_READLINE_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME readline ${_library_type})

add_library(ext_readline ${_library_type}
  readline.c
  readline_cli.c
)

# Add -Wno-strict-prototypes as depends on user libs.
target_compile_options(ext_readline PRIVATE -Wno-strict-prototypes)

if(NOT EXT_READLINE_LIBREADLINE)
  find_package(EDIT REQUIRED)

  if(EDIT_LIBRARIES)
    target_link_libraries(ext_readline PRIVATE ${EDIT_LIBRARIES})
  endif()

  if(EDIT_INCLUDE_DIRS)
    target_include_directories(ext_readline PRIVATE ${EDIT_INCLUDE_DIRS})
  endif()

  check_library_exists(edit readline "" _have_readline)
  if(NOT _have_readline)
    message(FATAL_ERROR "The Edit library required by ext/readline not found")
  endif()

  check_library_exists(edit rl_callback_read_char "" HAVE_RL_CALLBACK_READ_CHAR)
  check_library_exists(edit rl_on_new_line "" HAVE_RL_ON_NEW_LINE)
  check_library_exists(edit rl_completion_matches "" HAVE_RL_COMPLETION_MATCHES)
  check_library_exists(edit history_list "" HAVE_HISTORY_LIST)

  set(HAVE_LIBEDIT 1 CACHE INTERNAL "Define to 1 if libedit is used with ext/readline")
else()
  find_package(READLINE REQUIRED)

  if(READLINE_LIBRARIES)
    target_link_libraries(ext_readline PRIVATE ${READLINE_LIBRARIES})
  endif()

  if(READLINE_INCLUDE_DIRS)
    target_include_directories(ext_readline PRIVATE ${READLINE_INCLUDE_DIRS})
  endif()

  check_library_exists(readline readline "" _have_readline)
  if(NOT _have_readline)
    message(FATAL_ERROR "The Readline library required by ext/readline not found")
  endif()

  check_library_exists(readline rl_callback_read_char "" HAVE_RL_CALLBACK_READ_CHAR)
  check_library_exists(readline rl_on_new_line "" HAVE_RL_ON_NEW_LINE)
  check_library_exists(readline rl_completion_matches "" HAVE_RL_COMPLETION_MATCHES)

  set(HAVE_HISTORY_LIST 1 CACHE INTERNAL "Define to 1 if readline library has history_list()")
  set(HAVE_LIBREADLINE 1 CACHE INTERNAL "Define to 1 if libreadline is used with ext/readline")
endif()

# TODO: Check if this is needed. It seems that ncurses is not required.
set(CURSES_NEED_NCURSES TRUE)
find_package(Curses REQUIRED)

if(CURSES_LIBRARIES)
  target_link_libraries(ext_readline PRIVATE ${CURSES_LIBRARIES})
endif()

if(CURSES_INCLUDE_DIRS)
  target_include_directories(ext_readline PRIVATE ${CURSES_INCLUDE_DIRS})
endif()

if(CURSES_CFLAGS)
  target_compile_options(ext_readline PRIVATE ${CURSES_CFLAGS})
endif()

# TODO: Check for the obsolescent termcap library more properly.
if(NOT CURSES_FOUND)
  check_library_exists(termcap, tgetent "" _have_termcap_library)

  if(_have_termcap_library)
    target_link_libraries(ext_readline PRIVATE termcap)
  endif()
endif()
