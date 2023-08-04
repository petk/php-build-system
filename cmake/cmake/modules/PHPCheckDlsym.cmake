#[=============================================================================[
Check if dlsym() requires a leading underscore in symbol name.

function php_check_dlsym_needs_underscore()

Function sets the following variables:
``DLSYM_NEEDS_UNDERSCORE``
  Set to 1 if dlsym() requires a leading underscore in symbol names.
]=============================================================================]#

message(STATUS "Checking whether dlsym() requires a leading underscore in symbol names")

function(php_check_dlsym_needs_underscore)
  if(NOT CMAKE_CROSSCOMPILING)
    if(HAVE_DLFCN_H)
      set(DLFCN_DEFINED_MACRO "-DHAVE_DLFCN_H=1")
    else()
      set(DLFCN_DEFINED_MACRO)
    endif()

    try_run(
      RUN_RESULT_VAR
      COMPILE_RESULT_VAR
      ${CMAKE_BINARY_DIR}
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PHPCheckDlsym/check_dlsym_needs_underscore.c"
      COMPILE_DEFINITIONS ${DLFCN_DEFINED_MACRO}
      OUTPUT_VARIABLE RUN_OUTPUT
    )

    if(COMPILE_RESULT_VAR AND RUN_RESULT_VAR EQUAL 2)
      set(DLSYM_NEEDS_UNDERSCORE 1 CACHE INTERNAL "Define if dlsym() requires a leading underscore in symbol names.")
    endif()
  endif()
endfunction()

php_check_dlsym_needs_underscore()
