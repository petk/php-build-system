#[=============================================================================[
Test and set the alignment define for ZEND_MM. This also does the logarithmic
test for ZEND_MM.

Function: check_mm_alignment()
]=============================================================================]#

function(check_mm_alignment)
  message(STATUS "Check for MM alignment and log values")

  if(NOT CMAKE_CROSSCOMPILING)
    try_run(
      RUN_RESULT_VAR
      COMPILE_RESULT_VAR
      ${CMAKE_BINARY_DIR}
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PHPCheckMMAlignment/test_mm_alignment.c"
      RUN_OUTPUT_STDOUT_VARIABLE PHP_ZEND_MM_ALIGNMENT
    )

    if(RUN_RESULT_VAR EQUAL 0 AND COMPILE_RESULT_VAR)
      string(REGEX REPLACE "\n$" "" PHP_ZEND_MM_ALIGNMENT "${PHP_ZEND_MM_ALIGNMENT}")
      string(REPLACE " " ";" string_list "${PHP_ZEND_MM_ALIGNMENT}")

      list(GET string_list 0 ZEND_MM_ALIGNMENT)
      list(GET string_list 1 ZEND_MM_ALIGNMENT_LOG2)
      list(GET string_list 2 ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT)
    else()
      message(FATAL_ERROR "Test run failed!")
    endif()
  else()
    message(STATUS "Crosscompiling")

    set(ZEND_MM_ALIGNMENT 8)
    set(ZEND_MM_ALIGNMENT_LOG2 3)
    set(ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT 2)
  endif()

  set(ZEND_MM_ALIGNMENT ${ZEND_MM_ALIGNMENT} CACHE STRING "")
  set(ZEND_MM_ALIGNMENT_LOG2 ${ZEND_MM_ALIGNMENT_LOG2} CACHE STRING "")
  set(ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT ${ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT} CACHE STRING "")

  message(STATUS "ZEND_MM_ALIGNMENT = ${ZEND_MM_ALIGNMENT}")
  message(STATUS "ZEND_MM_ALIGNMENT_LOG2 = ${ZEND_MM_ALIGNMENT_LOG2}")
  message(STATUS "ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT = ${ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT}")
endfunction()

check_mm_alignment()
