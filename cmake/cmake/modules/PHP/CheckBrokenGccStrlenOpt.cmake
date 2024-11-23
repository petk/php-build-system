#[=============================================================================[
# PHP/CheckBrokenGccStrlenOpt

Early GCC 8 versions shipped with a strlen() optimization bug, so it didn't
properly handle the `char val[1]` struct hack. Fixed in GCC 8.3. If below check
is successful the -fno-optimize-strlen compiler flag should be added.
See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=86914

## Cache variables

* `PHP_HAVE_BROKEN_OPTIMIZE_STRLEN`
  Whether GCC has broken strlen() optimization.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

if(
  NOT CMAKE_C_COMPILER_ID STREQUAL "GNU"
  OR (
    CMAKE_C_COMPILER_ID STREQUAL "GNU"
    AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 8.3
  )
)
  return()
endif()

message(CHECK_START "Checking if GCC has broken strlen() optimization")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  # To reproduce the bug, the -O2 flag needs to be used, for example.
  set(CMAKE_REQUIRED_FLAGS -O2)

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
  ]] PHP_HAVE_BROKEN_OPTIMIZE_STRLEN)
cmake_pop_check_state()

if(PHP_HAVE_BROKEN_OPTIMIZE_STRLEN)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
