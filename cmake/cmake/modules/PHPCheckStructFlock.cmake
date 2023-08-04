#[=============================================================================[
Checks whether you have struct flock.

The module defines the following variables if compilation is successful:

``HAVE_STRUCT_FLOCK``
  Defined to 1 if struct flock is availabe.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for struct flock")

check_c_source_compiles("
#include <unistd.h>
#include <fcntl.h>

int main (void)
{
  struct flock x;
  return 0;
}
" HAVE_STRUCT_FLOCK)
