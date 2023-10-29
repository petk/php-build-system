#[=============================================================================[
Check if system has procctl().

Cache variables:

  HAVE_PROCCTL
    Set to true if system has working procctl().
]=============================================================================]#

include(CheckCSourceCompiles)

message(CHECK_START "Checking for procctl()")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <sys/procctl.h>

  int main(void) {
    procctl(0, 0, 0, 0);

    return 0;
  }
" HAVE_PROCCTL)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_PROCCTL)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
