#[=============================================================================[
Check whether writing to stdout works.

Cache variables:

  PHP_WRITE_STDOUT
    Set to 1 if write(2) works.
]=============================================================================]#

include(CheckCSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking whether writing to stdout works")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(CMAKE_CROSSCOMPILING)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(PHP_WRITE_STDOUT 1 CACHE INTERNAL "whether write(2) works")
  endif()
else()
  cmake_push_check_state(RESET)
    if(HAVE_UNISTD)
      set(CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H=1)
    endif()

    check_c_source_runs("
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

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(PHP_WRITE_STDOUT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
