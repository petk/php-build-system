#[=============================================================================[
Check if fclose declaration is missing.

Some systems have broken header files like SunOS has.

Cache variables:

  MISSING_FCLOSE_DECL
    Whether fclose declaration is missing.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Checking fclose declaration")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C "
    #include <stdio.h>

    int main(void) {
      int (*func)(void) = fclose;

      return 0;
    }
  " HAVE_FCLOSE_DECL)
cmake_pop_check_state()

if(NOT HAVE_FCLOSE_DECL)
  message(CHECK_FAIL "missing")

  set(
    MISSING_FCLOSE_DECL 1
    CACHE INTERNAL "Whether fclose declaration is missing"
  )
else()
  message(CHECK_PASS "found")
endif()
