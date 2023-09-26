#[=============================================================================[
Check if compiler supports inline keyword.

If successful the module sets the following variables:

INLINE_KEYWORD
  Set inline to __inline__ or __inline if one of those work, otherwise not set.
]=============================================================================]#

function(_php_check_inline)
  message(STATUS "Checking inline keyword for compiler")

  foreach(keyword "inline" "__inline__" "__inline")
    if(NOT DEFINED INLINE_KEYWORD)
      try_compile(
        C_HAS_${keyword}
        ${CMAKE_BINARY_DIR}
        "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckInline/check_inline.c"
        COMPILE_DEFINITIONS "-Dinline=${keyword}"
      )

      if(C_HAS_inline)
        message(STATUS "inline")
        unset(INLINE_KEYWORD CACHE)
        return()
      endif()

      if(C_HAS_${keyword})
        set(INLINE_KEYWORD ${keyword} CACHE INTERNAL "Set inline to __inline__ or __inline if one of those work, otherwise not set.")
      endif()
    endif()
  endforeach()

  if(NOT DEFINED INLINE_KEYWORD)
    message(FATAL_ERROR "Compiler doesn't support the inline keyword")
  endif()
endfunction()

_php_check_inline()
