#[=============================================================================[
Check whether you have struct flock.

The module sets the following variables:

HAVE_STRUCT_FLOCK
  Set to 1 if struct flock is available.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for struct flock")

check_c_source_compiles("
  #include <unistd.h>
  #include <fcntl.h>

  int main(void) {
    struct flock x;
    return 0;
  }
" HAVE_STRUCT_FLOCK)
