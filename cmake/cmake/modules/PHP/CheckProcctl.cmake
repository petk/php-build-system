#[=============================================================================[
Check if system has procctl().

The module sets the following variables:

HAVE_PROCCTL
  Set to true if system has working procctl().
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for procctl()")

check_c_source_compiles("
  #include <sys/procctl.h>

  int main(void) {
    procctl(0, 0, 0, 0);

    return 0;
  }
" HAVE_PROCCTL)
