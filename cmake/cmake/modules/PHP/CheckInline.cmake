#[=============================================================================[
Check if compiler supports inline, __inline__ or __inline keyword.

The inline keyword is part of the C99 standard and all decent compilers should
have it. At some point this check can be removed. See also Autoconf's
AC_C_INLINE and AX_C99_INLINE macros.

If compiler doesn't support any of the inline keywords, then an empty definition
needs to be used so the code compiles as a workaround.

Cache variables:

  INLINE_KEYWORD_DEFINITION
    Header definition line that sets the compiler's inline keyword.
]=============================================================================]#

function(_php_check_inline)
  message(CHECK_START "Checking C compiler inline keyword")

  foreach(keyword "inline" "__inline__" "__inline")
    try_compile(
      C_HAS_${keyword}
      ${CMAKE_BINARY_DIR}
      "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CheckInline/check_inline.c"
      COMPILE_DEFINITIONS "-Dinline=${keyword}"
    )

    if(C_HAS_inline)
      message(CHECK_PASS "inline")

      set(INLINE_STRING "/* #undef inline */" PARENT_SCOPE)

      return()
    endif()

    if(C_HAS_${keyword})
      message(CHECK_PASS "${keyword}")

      set(INLINE_STRING "#define inline ${keyword}" PARENT_SCOPE)

      return()
    endif()
  endforeach()

  if(NOT DEFINED INLINE_STRING)
    message(CHECK_FAIL "Compiler doesn't support the inline keyword")
    message(WARNING "Compiler doesn't support the C99 standard inline keyword")

    set(INLINE_STRING "#define inline" PARENT_SCOPE)
  endif()
endfunction()

if(NOT INLINE_KEYWORD_DEFINITION)
  _php_check_inline()

  set(
    INLINE_KEYWORD_DEFINITION
    "${INLINE_STRING}"
    CACHE INTERNAL
    "Compiler inline keyword definition"
  )

  unset(INLINE_STRING)
endif()
