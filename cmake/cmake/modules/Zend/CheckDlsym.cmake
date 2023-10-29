#[=============================================================================[
Check if dlsym() requires a leading underscore in symbol name.

Cache variables:

  DLSYM_NEEDS_UNDERSCORE
    Set to 1 if dlsym() requires a leading underscore in symbol names.
]=============================================================================]#

message(STATUS "Checking whether dlsym() requires a leading underscore in symbol names")

function(_php_check_dlsym_needs_underscore)
  if(NOT CMAKE_CROSSCOMPILING)
    if(HAVE_DLFCN_H)
      set(dlfcn_defined_macro "-DHAVE_DLFCN_H=1")
    endif()

    try_run(
      RUN_RESULT_VAR
      COMPILE_RESULT_VAR
      ${CMAKE_BINARY_DIR}
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckDlsym/check_dlsym_needs_underscore.c"
      COMPILE_DEFINITIONS ${dlfcn_defined_macro}
      OUTPUT_VARIABLE RUN_OUTPUT
    )

    if(COMPILE_RESULT_VAR AND RUN_RESULT_VAR EQUAL 2)
      set(DLSYM_NEEDS_UNDERSCORE 1 CACHE INTERNAL "Define if dlsym() requires a leading underscore in symbol names.")
    endif()
  endif()
endfunction()

_php_check_dlsym_needs_underscore()
