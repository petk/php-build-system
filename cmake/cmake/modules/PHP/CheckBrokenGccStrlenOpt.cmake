#[=============================================================================[
Early releases of GCC 8 shipped with a strlen() optimization bug, so they didn't
properly handle the 'char val[1]' struct hack. See https://bugs.php.net/76510.
If check is successful the -fno-optimize-strlen compiler flag should be used.

Cache variables:

  HAVE_BROKEN_OPTIMIZE_STRLEN
    Whether GCC's optimize-strlen is broken.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
  return()
endif()

message(CHECK_START "Checking for broken GCC optimize-strlen")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_runs(C [[
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>

    struct s {
      int i;
      char c[1];
    };

    int main(void)
    {
      struct s *s = malloc(sizeof(struct s) + 3);
      s->i = 3;
      strcpy(s->c, "foo");

      return strlen(s->c+1) == 2;
    }
  ]] HAVE_BROKEN_OPTIMIZE_STRLEN)
cmake_pop_check_state()

if(HAVE_BROKEN_OPTIMIZE_STRLEN)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
