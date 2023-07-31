#[=============================================================================[
Check if flush should be called explicitly after buffered io.

Function: check_flush_io()
]=============================================================================]#

include(CheckCSourceRuns)

function(php_check_flush_io)
  message(STATUS "Checking whether flush should be called explicitly after a buffered io")

  if(CMAKE_CROSSCOMPILING)
    message(STATUS "Cross compiling: no")
    return()
  endif()

  if(HAVE_UNISTD_H)
    set(UNISTD_DEFINED_MACRO "-DHAVE_UNISTD_H=1")
  else()
    set(UNISTD_DEFINED_MACRO)
  endif()

  try_run(
    RUN_RESULT_VAR
    COMPILE_RESULT_VAR
    ${CMAKE_BINARY_DIR}
    "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PHPCheckFlushIo/check_flush_io.c"
    COMPILE_DEFINITIONS ${UNISTD_DEFINED_MACRO}
    OUTPUT_VARIABLE RUN_OUTPUT
  )

  if(NOT COMPILE_RESULT_VAR)
    message(FATAL_ERROR "Error when compiling the check_flush_io.c program:\n${RUN_OUTPUT}")
  endif()

  if(RUN_RESULT_VAR EQUAL 0)
    message(STATUS "no")
  else()
    message(STATUS "yes")
    set(HAVE_FLUSHIO 1 CACHE STRING "Define if flush should be called explicitly after a buffered io.")
  endif()
endfunction()

php_check_flush_io()
