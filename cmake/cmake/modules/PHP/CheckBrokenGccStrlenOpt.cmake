#[=============================================================================[
Early releases of GCC 8 shipped with a strlen() optimization bug, so they didn't
properly handle the `char val[1]` struct hack. See bug #76510. If check is
successful the -fno-optimize-strlen compiler flag should be used.

Cache variables:

  HAVE_BROKEN_OPTIMIZE_STRLEN
    Set to 1 if GCC's optimize-strlen is broken.
]=============================================================================]#

include(CheckCSourceRuns)

if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
  return()
endif()

message(CHECK_START "Checking for broken GCC optimize-strlen")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>

    struct s {
      int i;
      char c[1];
    };

    int main(void) {
      struct s *s = malloc(sizeof(struct s) + 3);
      s->i = 3;
      strcpy(s->c, \"foo\");

      return strlen(s->c+1) == 2;
    }
  " HAVE_BROKEN_OPTIMIZE_STRLEN)
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_BROKEN_OPTIMIZE_STRLEN)
  message(CHECK_PASS "yes, adding -fno-optimize-strlen")
elseif(CMAKE_CROSSCOMPILING)
  message(CHECK_FAIL "no (cross-compiling)")
else()
  message(CHECK_FAIL "no")
endif()
