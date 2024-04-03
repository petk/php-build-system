#[=============================================================================[
Check if function exists in one of the libraries.

Depending on the system, C functions can be located in one of the default linked
libraries when using compiler (for example, C library), while they can be also
in separate system libraries. The usual check_symbol_exists() doesn't find them
unless the CMAKE_REQUIRED_LIBRARIES is also specified.

CMake at the time of this writing doesn't have a built-in command where symbol
is checked using given headers and if not found in default linked libraries, a
given list of libraries is searched and found library is linked as needed.

The logic in this module is somehow following the Autoconf's AC_SEARCH_LIBS.

Module exposes the following function:

  php_search_libraries(
    <function>
    <header(s)>
    <function_variable>
    [LIBRARIES <library>...]
    [LIBRARY_VARIABLE <library_variable>]
    [TARGET <target> <PRIVATE|PUBLIC|INTERFACE>]
  )

    Check that the <function> is available after including the <header> (or a
    semicolon separated list of <headers>) and store the result in an internal
    cache variable <function_variable>.

    LIBRARIES
      If function is not found in the default libraries (C library), then the
      LIBRARIES list is searched.

    LIBRARY_VARIABLE
      When function is not found in the default libraries, the resulting library
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

include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakePushCheckState)

function(php_search_libraries)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed             # prefix
    ""                 # options
    "LIBRARY_VARIABLE" # one-value keywords
    "LIBRARIES;TARGET" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  set(function ${ARGV0})
  set(headers ${ARGV1})
  set(result_function_variable ${ARGV2})
  set(result_library_variable ${parsed_LIBRARY_VARIABLE})
  set(libraries ${parsed_LIBRARIES})

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
    string(MAKE_C_IDENTIFIER "${header}" const)
    string(TOUPPER "${const}" const)

    cmake_push_check_state()
      cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
      if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
        set(CMAKE_REQUIRED_QUIET TRUE)
      endif()
      check_include_file(${header} HAVE_${const})
    cmake_pop_check_state()

    if(HAVE_${const})
      list(APPEND checked_headers ${header})
    endif()
  endforeach()

  # First, check if symbol exists without linking additional libraries.
  check_symbol_exists(
    ${function}
    "${checked_headers}"
    ${result_function_variable}
  )

  if(${${result_function_variable}})
    return()
  endif()

  # Now, check if any library needs to be linked.
  unset(${result_function_variable} CACHE)

  # Check if linking library helps finding the function.
  foreach(library ${libraries})
    if(NOT CMAKE_REQUIRED_QUIET)
      message(CHECK_START "Looking for ${function} in ${library}")
    endif()

    cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_LIBRARIES ${library})
      set(CMAKE_REQUIRED_QUIET TRUE)

      # Instead of using the check_library_exists() or check_function_exists(),
      # the check_symbol_exists() also works for edge cases, where the symbol
      # might be a macro definition. It would not be found using the other two
      # commands because they don't include required headers.
      check_symbol_exists(
        ${function}
        "${checked_headers}"
        ${result_function_variable}
      )
    cmake_pop_check_state()

    if(${${result_function_variable}})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(CHECK_PASS "found")
      endif()

      if(result_library_variable)
        set(${result_library_variable} ${library} PARENT_SCOPE)
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

      unset(${result_function_variable} CACHE)
    endif()
  endforeach()
endfunction()
