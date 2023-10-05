#[=============================================================================[
Check if system has working prctl().

The module sets the following variables:

HAVE_PRCTL
  Set to true if system has working prctl().
]=============================================================================]#

include(CheckCSourceCompiles)

message(CHECK_START "Checking for prctl()")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <sys/prctl.h>

  int main(void) {
    prctl(0, 0, 0, 0, 0);

    return 0;
  }
" HAVE_PRCTL)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_PRCTL)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
