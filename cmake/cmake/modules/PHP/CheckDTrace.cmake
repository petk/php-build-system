#[=============================================================================[
Check for DTrace.

Module sets the following variables:

HAVE_DTRACE
  Set to 1 if DTrace support is enabled.
]=============================================================================]#

include(CheckIncludeFile)

function(_php_check_dtrace)
  if(NOT PHP_DTRACE)
    return()
  endif()

  message(STATUS "Checking for DTrace support")

  check_include_file(sys/sdt.h HAVE_SYS_SDT_H)

  if(NOT HAVE_SYS_SDT_H)
    message(FATAL_ERROR "Cannot find sys/sdt.h which is required for DTrace support")
    return()
  endif()

  find_program(PROG_DTRACE dtrace PATHS /usr/bin /usr/sbin)

  if(NOT PROG_DTRACE)
    message(FATAL_ERROR "Could not find the dtrace generation tool. Please install DTrace.")
  endif()

  # Generate header file.
  add_custom_command(
    OUTPUT "${CMAKE_SOURCE_DIR}/Zend/zend_dtrace_gen.h"
    COMMAND ${PROG_DTRACE} -h -C -s ${CMAKE_SOURCE_DIR}/Zend/zend_dtrace.d -o ${CMAKE_SOURCE_DIR}/Zend/zend_dtrace_gen.h
    DEPENDS "${CMAKE_SOURCE_DIR}/Zend/zend_dtrace.d"
    COMMENT "Generating DTrace ${CMAKE_SOURCE_DIR}/Zend/zend_dtrace_gen.h"
  )

  add_custom_target(
    GenerateDTraceHeader
    DEPENDS ${CMAKE_SOURCE_DIR}/Zend/zend_dtrace_gen.h
    COMMENT "Generating DTrace header Zend/zend_dtrace_gen.h"
  )

  add_custom_target(
    patch_dtrace_file
    COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckDTrace/PatchDtraceFile.cmake"
    DEPENDS GenerateDTraceHeader
    COMMENT "Patching DTrace header Zend/zend_dtrace_gen.h"
  )

  add_library(zend_dtrace
    main/main.c
    Zend/zend_API.c
    Zend/zend_execute.c
    Zend/zend_exceptions.c
    Zend/zend_dtrace.c
    Zend/zend.c
  )

  add_dependencies(zend_dtrace patch_dtrace_file)

  set(HAVE_DTRACE 1 CACHE INTERNAL "Whether to enable DTrace support")

  message(STATUS "DTrace enabled")
endfunction()

_php_check_dtrace()
