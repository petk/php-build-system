#[=============================================================================[
Check for a working POSIX fnmatch() function.

Some versions of Solaris, SCO, and the GNU C Library have a broken or
incompatible fnmatch. When cross-compiling we only enable it for Linux systems.

Module sets the following variables:

HAVE_FNMATCH
  Set to 1 if fnmatch is a working POSIX variant.
]=============================================================================]#

function(_php_check_fnmatch)
  if(CMAKE_CROSSCOMPILING)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
      set(successful TRUE)
    endif()
  else()
    try_run(
      RUN_RESULT_VAR
      COMPILE_RESULT_VAR
      ${CMAKE_BINARY_DIR}
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckFnmatch/check_fnmatch.c"
      OUTPUT_VARIABLE RUN_OUTPUT
    )

    if(COMPILE_RESULT_VAR AND RUN_RESULT_VAR EQUAL 0)
      set(successful TRUE)
    endif()
  endif()

  if(successful)
    set(HAVE_FNMATCH 1 CACHE INTERNAL "Define to 1 if your system has a working POSIX fnmatch function.")
  endif()
endfunction()

_php_check_fnmatch()
