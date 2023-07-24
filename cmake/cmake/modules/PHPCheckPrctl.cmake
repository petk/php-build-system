#[=============================================================================[
Checks if we have working prctl.

The module defines the following variables:

``HAVE_PRCTL``
  Defined to 1 if we have working prctl.
]=============================================================================]#

message(STATUS "Checking for prctl")

include(CheckCSourceCompiles)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "no")
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

  if(HAVE_PRCTL)
    set(HAVE_PRCTL 1 CACHE STRING "do we have prctl?")
    message(STATUS "yes")
  else()
    message(STATUS "no")
  endif()
endif()
