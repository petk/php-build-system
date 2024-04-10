#[=============================================================================[
Check if symbol exists in given header(s). If not found in default linked
libraries (for example, C library), a given list of libraries is searched and
found library is linked as needed.

Depending on the system, C functions can be located in one of the default linked
libraries (for example, C library) when using compiler, or they can be also in
separate system libraries. The usual check_symbol_exists() doesn't find them
unless the CMAKE_REQUIRED_LIBRARIES is also specified.

For example, math functions (math.h) can be on most *nix systems in math library
(m), however macOS, Windows and Haiku have them in C library. So linking math
library (-lm) isn't always necessary. Also, many systems might be in transition
of moving functions from their dedicated libraries to C library. For example,
illumos-based systems (-lnsl...), and similar.

The logic in this module is somehow following the Autoconf's AC_SEARCH_LIBS.

Module exposes the following function:

  php_search_libraries(
    <symbol>
    <symbol_variable>
    HEADERS <header(s)>
    [LIBRARIES <library>...]
    [LIBRARY_VARIABLE <library_variable>]
    [TARGET <target> <PRIVATE|PUBLIC|INTERFACE>]
  )

    Check that the <symbol> is available after including the <header> (or a list
    of <headers>) and store the result in an internal cache variable
    <symbol_variable>.

    HEADERS
      A header (or a list of headers) where to look for the symbol declaration.

    LIBRARIES
      If symbol is not found in the default libraries (C library), then the
      LIBRARIES list is searched.

    LIBRARY_VARIABLE
      When symbol is not found in the default libraries, the resulting library
      is stored in this regular variable name.

    TARGET
      If the TARGET is given, the resulting library is linked to a given
      <target> with the scope of PRIVATE, PUBLIC, or INTERFACE. It is
      homogeneous to
      target_link_libraries(<target> PRIVATE|PUBLIC|INTERFACE <library>).

  The following variables may be set before calling this function to modify the
  way the check is run. See
  https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html

    CMAKE_REQUIRED_FLAGS
    CMAKE_REQUIRED_DEFINITIONS
    CMAKE_REQUIRED_INCLUDES
    CMAKE_REQUIRED_LINK_OPTIONS
    CMAKE_REQUIRED_LIBRARIES
    CMAKE_REQUIRED_QUIET
]=============================================================================]#

include_guard(GLOBAL)

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CMakePushCheckState)

function(php_search_libraries)
  cmake_parse_arguments(
    PARSE_ARGV
    2
    parsed                     # prefix
    ""                         # options
    "LIBRARY_VARIABLE"         # one-value keywords
    "HEADERS;LIBRARIES;TARGET" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  set(symbol ${ARGV0})
  set(symbol_result_variable ${ARGV1})
  set(headers ${parsed_HEADERS})
  set(libraries ${parsed_LIBRARIES})
  set(library_result_variable ${parsed_LIBRARY_VARIABLE})

  if(NOT parsed_HEADERS)
    message(FATAL_ERROR "php_search_libraries: missing HEADERS")
  endif()

  # Validate optional TARGET.
  if(parsed_TARGET)
    list(GET parsed_TARGET 0 target)
    list(GET parsed_TARGET 1 target_scope)

    if(NOT TARGET ${target})
      message(FATAL_ERROR "Bad TARGET arguments: ${target} is not a target")
    endif()

    if(NOT target_scope)
      message(
        FATAL_ERROR
        "Bad TARGET arguments: Target scope PRIVATE|PUBLIC|INTERFACE is missing"
      )
    endif()

    if(NOT target_scope MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
      message(
        FATAL_ERROR
        "Bad TARGET arguments: ${target_scope} is not a target scope. Use one "
        "of PRIVATE|PUBLIC|INTERFACE."
      )
    endif()
  endif()

  # Check if given header(s) can be included.
  foreach(header ${headers})
    string(MAKE_C_IDENTIFIER "HAVE_${header}" const)
    string(TOUPPER "${const}" const)

    cmake_push_check_state()
      cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
      if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
        set(CMAKE_REQUIRED_QUIET TRUE)
      endif()

      # Check multiple headers appended one after the other instead of a single
      # header check. In some edge cases certain headers are not self-contained
      # and need additional headers. For example, arpa/nameser.h on FreeBSD<=13
      # needs sys/types.h to work. On Solaris/illumos, similar bug happens when
      # including sys/loadavg.h without sys/types.h.
      check_include_files("${headers_found};${header}" ${const})
    cmake_pop_check_state()

    if(${${const}})
      list(APPEND headers_found ${header})
    endif()
  endforeach()

  # First, check if symbol exists without linking additional libraries.
  check_symbol_exists(
    ${symbol}
    "${headers_found}"
    ${symbol_result_variable}
  )

  if(${${symbol_result_variable}})
    return()
  endif()

  # Now, check if any library needs to be linked.
  unset(${symbol_result_variable} CACHE)

  # Check if linking library helps finding the symbol.
  foreach(library ${libraries})
    if(NOT CMAKE_REQUIRED_QUIET)
      message(CHECK_START "Looking for ${symbol} in ${library}")
    endif()

    cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_LIBRARIES ${library})
      set(CMAKE_REQUIRED_QUIET TRUE)

      # Instead of using the check_library_exists() or check_function_exists(),
      # the check_symbol_exists() also works for edge cases, where the symbol
      # might be a macro definition. It would not be found using the other two
      # commands because they don't include required headers.
      check_symbol_exists(
        ${symbol}
        "${headers_found}"
        ${symbol_result_variable}
      )
    cmake_pop_check_state()

    if(${${symbol_result_variable}})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "found")
      endif()

      if(library_result_variable)
        set(${library_result_variable} ${library} PARENT_SCOPE)
      endif()

      # Link found library to the optionally given target.
      if(target)
        target_link_libraries(${target} ${target_scope} ${library})
      endif()

      return()
    else()
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_FAIL "not found")
      endif()

      unset(${symbol_result_variable} CACHE)
    endif()
  endforeach()
endfunction()
