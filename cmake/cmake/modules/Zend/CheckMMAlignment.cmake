#[=============================================================================[
Test and set the alignment define for ZEND_MM. This also does the logarithmic
test for ZEND_MM.

Cache variables:

  ZEND_MM_ALIGNMENT

  ZEND_MM_ALIGNMENT_LOG2

  ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT
]=============================================================================]#

function(_php_check_mm_alignment)
  message(STATUS "Checking for MM alignment and log values")

  if(NOT CMAKE_CROSSCOMPILING)
    try_run(
      RUN_RESULT_VAR
      COMPILE_RESULT_VAR
      ${CMAKE_BINARY_DIR}
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckMMAlignment/test_mm_alignment.c"
      RUN_OUTPUT_STDOUT_VARIABLE PHP_ZEND_MM_ALIGNMENT
    )

    if(RUN_RESULT_VAR EQUAL 0 AND COMPILE_RESULT_VAR)
      string(REGEX REPLACE "\n$" "" PHP_ZEND_MM_ALIGNMENT "${PHP_ZEND_MM_ALIGNMENT}")
      string(REPLACE " " ";" string_list "${PHP_ZEND_MM_ALIGNMENT}")

      list(GET string_list 0 zend_mm_alignment)
      list(GET string_list 1 zend_mm_alignment_log2)
      list(GET string_list 2 zend_mm_need_eight_byte_realignment)
    else()
      message(WARNING "MM alignment values were not set")
    endif()
  else()
    message(STATUS "Crosscompiling")

    set(zend_mm_alignment 8)
    set(zend_mm_alignment_log2 3)
    set(zend_mm_need_eight_byte_realignment 0)
  endif()

  set(ZEND_MM_ALIGNMENT ${zend_mm_alignment} CACHE INTERNAL "")
  set(ZEND_MM_ALIGNMENT_LOG2 ${zend_mm_alignment_log2} CACHE INTERNAL "")
  set(ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT ${zend_mm_need_eight_byte_realignment} CACHE INTERNAL "")

  message(STATUS "ZEND_MM_ALIGNMENT = ${ZEND_MM_ALIGNMENT}")
  message(STATUS "ZEND_MM_ALIGNMENT_LOG2 = ${ZEND_MM_ALIGNMENT_LOG2}")
  message(STATUS "ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT = ${ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT}")
endfunction()

_php_check_mm_alignment()
