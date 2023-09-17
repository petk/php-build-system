#[=============================================================================[
Early releases of GCC 8 shipped with a strlen() optimization bug, so they didn't
properly handle the `char val[1]` struct hack. See bug #76510.

If check is successful the module adds the following compiler flags:

-fno-optimize-strlen
]=============================================================================]#

include(CheckCSourceRuns)

if(NOT (CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
  return()
endif()

message(STATUS "Checking for broken gcc optimize-strlen")

if(CMAKE_CROSSCOMPILING)
  set(_have_broken_optimize_strlen OFF)
else()
  check_c_source_runs("
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>
    struct s
    {
      int i;
      char c[1];
    };
    int main(void)
    {
      struct s *s = malloc(sizeof(struct s) + 3);
      s->i = 3;
      strcpy(s->c, \"foo\");
      return strlen(s->c+1) == 2;
    }
  " _have_broken_optimize_strlen)
endif()

if(_have_broken_optimize_strlen)
  message(STATUS "Appending -fno-optimize-strlen")
  # TODO: Fix this better.
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-optimize-strlen" CACHE STRING "C Compiler Flags")
else()
  message(STATUS "no")
endif()

unset(_have_broken_optimize_strlen)
