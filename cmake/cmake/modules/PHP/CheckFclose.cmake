#[=============================================================================[
Check if fclose declaration is missing.

Some systems have broken header files like SunOS has.

Cache variables:

  MISSING_FCLOSE_DECL
    Whether fclose declaration is missing.
]=============================================================================]#

include(CheckCSourceCompiles)

message(CHECK_START "Checking for fclose declaration")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <stdio.h>

  int main(void) {
    int (*func)() = fclose;

    return 0;
  }
" HAVE_FCLOSE_DECL)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(NOT HAVE_FCLOSE_DECL)
  message(CHECK_FAIL "missing")

  set(
    MISSING_FCLOSE_DECL 1
    CACHE INTERNAL "Whether fclose declaration is missing"
  )
else()
  message(CHECK_PASS "ok")
endif()
