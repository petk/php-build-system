#[=============================================================================[
Check for dtrace.

Function: check_dtrace()
]=============================================================================]#

include(CheckIncludeFile)

function(check_dtrace)
  option(DTRACE "Whether to enable DTrace support" OFF)

  if(NOT DTRACE)
    return()
  endif()

  check_include_file(sys/sdt.h HAVE_SYS_SDT_H)

  if(NOT HAVE_SYS_SDT_H)
    message(FATAL_ERROR "Cannot find sys/sdt.h which is required for DTrace support")
    return()
  endif()

  set(HAVE_DTRACE 1 CACHE STRING "Whether to enable DTrace support")

endfunction()
