#[=============================================================================[
Check if system has working prctl().

The module sets the following variables:

HAVE_PRCTL
  Set to true if system has working prctl().
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for prctl()")

check_c_source_compiles("
  #include <sys/prctl.h>

  int main(void) {
    prctl(0, 0, 0, 0, 0);

    return 0;
  }
" HAVE_PRCTL)
