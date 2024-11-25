#[=============================================================================[
# PHP/CheckWrite

Check whether writing to stdout works.

## Cache variables

* `PHP_WRITE_STDOUT`

  Whether `write(2)` works.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckIncludeFile)
include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking whether writing to stdout works")

if(
  NOT DEFINED PHP_WRITE_STDOUT_EXITCODE
  AND CMAKE_CROSSCOMPILING
  AND NOT CMAKE_CROSSCOMPILING_EMULATOR
  AND CMAKE_SYSTEM_NAME MATCHES "^(Linux|Midipix)$"
)
  set(PHP_WRITE_STDOUT_EXITCODE 0)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_include_file(unistd.h HAVE_UNISTD_H)

  if(HAVE_UNISTD_H)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -DHAVE_UNISTD_H)
  endif()

  check_source_runs(C [[
    #ifdef HAVE_UNISTD_H
    # include <unistd.h>
    #endif

    #define TEXT "This is the test message -- "

    int main(void)
    {
      int n;

      n = write(1, TEXT, sizeof(TEXT)-1);
      return (!(n == sizeof(TEXT)-1));
    }
  ]] PHP_WRITE_STDOUT)
cmake_pop_check_state()

if(PHP_WRITE_STDOUT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
