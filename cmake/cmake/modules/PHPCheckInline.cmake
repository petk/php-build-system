#[=============================================================================[
Check if compiler supports inline keyword.

If successful the module sets the following variables:

``INLINE_KEYWORD``
  Set inline to __inline__ or __inline if one of those work, otherwise not set.
]=============================================================================]#

function(php_check_inline)
  message(STATUS "Checking inline keyword for compiler")

  foreach(KEYWORD "inline" "__inline__" "__inline")
    if(NOT DEFINED inline)
      try_compile(
        C_HAS_${KEYWORD}
        ${CMAKE_BINARY_DIR}
        "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/PHPCheckInline/check_inline.c"
        COMPILE_DEFINITIONS "-Dinline=${KEYWORD}"
      )

      if(C_HAS_inline)
        message(STATUS "inline")
        unset(inline)
        return()
      endif()

      if(C_HAS_${KEYWORD})
        set(inline ${KEYWORD} CACHE INTERNAL "Set inline to __inline__ or __inline if one of those work, otherwise not set.")
      endif()
    endif()
  endforeach()

  if(NOT DEFINED inline)
    message(FATAL_ERROR "Compiler doesn't support the inline keyword")
  endif()
endfunction()

php_check_inline()
