#[=============================================================================[
Checks if we have working prctl.

The module defines the following variables:

HAVE_PRCTL
  Defined to 1 if we have working prctl.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for prctl")

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no (cross-compiling)")
else()
  check_c_source_compiles("
    #include <sys/prctl.h>
    int
    main (void)
    {
      prctl(0, 0, 0, 0, 0);
      ;
      return 0;
    }
  " HAVE_PRCTL)
endif()
