#[=============================================================================[
Check if compiler supports 'inline', '__inline__', or '__inline' keyword.

The 'inline' keyword is part of the C99 standard and all decent compilers should
have it. See also Autoconf's 'AC_C_INLINE' and 'AX_C99_INLINE' macros.

If compiler doesn't support any of the inline keywords, then an empty definition
needs to be used so the code compiles as a workaround.

Result/cache variables:

* PHP_INLINE_KEYWORD_CODE - Header definition line that sets the compiler's
  'inline' keyword.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(PHP_INLINE_KEYWORD_CODE "/* #undef inline */")
  return()
endif()

function(_php_check_inline result)
  set(${result} "")

  message(CHECK_START "Checking C compiler inline keyword")

  foreach(keyword "inline" "__inline__" "__inline")
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_DEFINITIONS -Dinline=${keyword})
      set(CMAKE_REQUIRED_QUIET TRUE)

      check_source_compiles(C [[
        #ifndef __cplusplus
          typedef int foo_t;
          static inline foo_t static_foo(void) { return 0; }
          inline foo_t foo(void) { return 0; }
        #endif

        int main(void) { return 0; }
      ]] PHP_HAS_${keyword})
    cmake_pop_check_state()

    if(PHP_HAS_inline)
      message(CHECK_PASS "inline")

      set(${result} "/* #undef inline */")

      return(PROPAGATE ${result})
    endif()

    if(PHP_HAS_${keyword})
      message(CHECK_PASS "${keyword}")

      set(${result} "#define inline ${keyword}")

      return(PROPAGATE ${result})
    endif()
  endforeach()

  if(NOT ${result})
    message(CHECK_FAIL "not supported")
    message(WARNING "Compiler doesn't support the C99 standard inline keyword")

    set(${result} "#define inline")

    return(PROPAGATE ${result})
  endif()
endfunction()

if(NOT DEFINED PHP_INLINE_KEYWORD_CODE)
  _php_check_inline(PHP_INLINE_KEYWORD_CODE)

  set(
    PHP_INLINE_KEYWORD_CODE
    "${PHP_INLINE_KEYWORD_CODE}"
    CACHE INTERNAL
    "Compiler inline keyword definition."
  )
endif()
