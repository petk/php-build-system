#[=============================================================================[
Checks if we have procctl.

The module defines the following variables:

HAVE_PROCCTL
  Defined to 1 if we have working procctl.
]=============================================================================]#

message(STATUS "Checking for procctl")

include(CheckCSourceCompiles)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no")
else()
  check_c_source_compiles("
    #include <sys/procctl.h>
    int
    main (void)
    {
      procctl(0, 0, 0, 0);
      ;
      return 0;
    }
  " HAVE_PROCCTL)
endif()
