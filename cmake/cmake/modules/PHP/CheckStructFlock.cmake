#[=============================================================================[
Check whether system has struct flock.

Cache variables:

  HAVE_STRUCT_FLOCK
    Whether struct flock is available.
]=============================================================================]#

include(CheckCSourceCompiles)

message(CHECK_START "Checking for struct flock")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <unistd.h>
  #include <fcntl.h>

  int main(void) {
    struct flock x;

    return 0;
  }
" HAVE_STRUCT_FLOCK)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_STRUCT_FLOCK)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
