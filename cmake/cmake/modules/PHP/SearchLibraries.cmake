#[=============================================================================[
Search for a library defining function if it's not already available. Similar
implementation as the Autoconf's AC_SEARCH_LIBS().

Function:
  php_search_libraries(<function>
                       <header(s)>
                       <function_variable>
                       <library_variable>
                       LIBRARIES <library>...)

    Check that the <function> is available after including the <header> (or a
    semicolon separated list of headers) and store the result in an internal
    cache variable <function_variable>. If function is not found, then
    the listed libraries are searched and the resulting library is stored in the
    <library_variable>.
]=============================================================================]#

include(CheckLibraryExists)
include(CheckSymbolExists)

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

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT parsed_LIBRARIES)
    message(
      FATAL_ERROR
      "php_search_libraries expects libraries where to search function"
    )
  endif()

  set(function ${ARGV0})
  set(header ${ARGV1})
  set(result_function_variable ${ARGV2})
  set(result_library_variable ${ARGV3})
  set(libraries ${parsed_LIBRARIES})

  # First, check if symbol exists without linking additional libraries.
  check_symbol_exists(
    ${function}
    "${header}"
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
