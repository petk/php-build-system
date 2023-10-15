#[=============================================================================[
Check if compiler supports inline, __inline__ or __inline keyword.

The inline keyword is part of the C99 standard and all decent compilers should
have it. At some point this check can be removed. See also Autoconf's
AC_C_INLINE and AX_C99_INLINE macros.

If compiler doesn't support any of the inline keywords, then an empty compile
definition is used so the code compiles as a workaround.

If successful the module sets the following variables:

INLINE_KEYWORD
  Set inline to __inline__ or __inline if one of those work, otherwise not set.
]=============================================================================]#

function(_php_check_inline)
  message(STATUS "Checking inline keyword for compiler")

  foreach(keyword "inline" "__inline__" "__inline")
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
      message(STATUS "${keyword}")
      set(INLINE_KEYWORD ${keyword} CACHE INTERNAL "Set inline to __inline__ or __inline if one of those work, otherwise not set.")
      return()
    endif()
  endforeach()

  if(NOT DEFINED INLINE_KEYWORD)
    # TODO: use INTERFACE library.
    add_compile_definitions(inline)
    message(WARNING "Compiler doesn't support the inline keyword")
  endif()
endfunction()

_php_check_inline()
