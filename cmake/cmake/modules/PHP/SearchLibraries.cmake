#[=============================================================================[
Check if function exists in one of the libraries.

Function:
  php_search_libraries(<function>
                       <header(s)>
                       <function_variable>
                       <library_variable>
                       [LIBRARIES <library>...])

    Check that the <function> is available after including the <header> (or a
    semicolon separated list of headers) and store the result in an internal
    cache variable <function_variable>. If function is not found in a standard C
    library, then the listed libraries are searched and the resulting library is
    stored in the <library_variable>.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)

function(php_search_libraries)
  cmake_parse_arguments(
    PARSE_ARGV
    4
    parsed      # prefix
    ""          # options
    ""          # one-value keywords
    "LIBRARIES" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  set(function ${ARGV0})
  set(headers ${ARGV1})
  set(result_function_variable ${ARGV2})
  set(result_library_variable ${ARGV3})
  set(libraries ${parsed_LIBRARIES})

  # Check if given header(s) can be included.
  foreach(header ${headers})
    string(REGEX REPLACE "[ ./]" "_" const ${header})
    string(TOUPPER ${const} const_upper)

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_include_file(${header} HAVE_${const_upper})
    cmake_pop_check_state()

    if(HAVE_${const_upper})
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

  foreach(library ${libraries})
    check_library_exists(${library} ${function} "" ${result_function_variable})

    if(${${result_function_variable}})
      set(${result_library_variable} ${library} PARENT_SCOPE)

      return()
    else()
      unset(${result_function_variable} CACHE)
    endif()
  endforeach()
endfunction()
