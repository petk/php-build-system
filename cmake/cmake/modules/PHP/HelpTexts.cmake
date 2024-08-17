#[=============================================================================[
Get help texts from all cache variables.

Each cache variable gets its <cache-variable-name>_HELP variable with value of
the HELPSTRING property that is usually set by the 4th argument:
set(<cache-variable-name> CACHE <type> "<help-string>")

Some cache variables are created by CMake internally and there some replacements
are done.
]=============================================================================]#

include_guard(GLOBAL)

get_cmake_property(variables CACHE_VARIABLES)
foreach(var ${variables})
  get_property(helpstring CACHE ${var} PROPERTY HELPSTRING)

  # Adjust some common header help strings.
  if(helpstring MATCHES "^Have include (.*\.h)$")
    set(helpstring "Define to 1 if you have the <${CMAKE_MATCH_1}> header file.")
  endif()

  if("${var}" STREQUAL "HAVE_DECL_ARC4RANDOM_BUF")
    set(helpstring "Define to 1 if you have the declaration of 'arc4random_buf', and to 0 if you don't.")
  endif()

  string(LENGTH "${helpstring}" length)

  if(length GREATER 77)
    string(REGEX REPLACE "[ \t]*[\r\n]+[ \t]*" " " helpstring "${helpstring}")
    # Temporary store possible semicolons to different placeholder because they
    # are list delimiters in CMake.
    string(REPLACE ";" "@@@" helpstring "${helpstring}")
    # Split string into a semicolon-separated list.
    string(REPLACE " " ";" list "${helpstring}")

    set(new_helpstring)
    set(line)
    foreach(word ${list})
      string(APPEND new_helpstring "${word} ")
      string(APPEND line "${word} ")
      string(LENGTH "${line}" length)
      if(length GREATER 77)
        string(APPEND new_helpstring "\n   ")
        set(line)
      endif()
    endforeach()
    set(helpstring "${new_helpstring}")

    # Restore possible semicolons.
    string(REPLACE "@@@" ";" helpstring "${helpstring}")
  endif()

  # Remove leading and trailing whitespace.
  string(STRIP "${helpstring}" helpstring)

  set(${var}_HELP "${helpstring}")
endforeach()
