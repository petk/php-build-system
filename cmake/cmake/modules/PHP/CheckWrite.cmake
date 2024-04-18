#[=============================================================================[
Check whether writing to stdout works.

Cache variables:

  PHP_WRITE_STDOUT
    Whether write(2) works.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking whether writing to stdout works")

if(CMAKE_CROSSCOMPILING AND CMAKE_SYSTEM_NAME MATCHES "^(Linux|Midipix)$")
  set(PHP_WRITE_STDOUT 1 CACHE INTERNAL "Whether write(2) works")
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    if(HAVE_UNISTD_H)
      list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H=1)
    endif()

    check_source_runs(C "
      #ifdef HAVE_UNISTD_H
      # include <unistd.h>
      #endif

      #define TEXT \"This is the test message -- \"

      int main(void) {
        int n;

        n = write(1, TEXT, sizeof(TEXT)-1);
        return (!(n == sizeof(TEXT)-1));
      }
    " PHP_WRITE_STDOUT)
  cmake_pop_check_state()
endif()

if(PHP_WRITE_STDOUT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
