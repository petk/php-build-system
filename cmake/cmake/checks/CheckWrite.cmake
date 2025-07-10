#[=============================================================================[
Check whether write(2) can successfully write to stdout.

On Windows, _write() (and its deprecated alias write()) can also write to stdout
but this PHP code uses this for POSIX targets only.

Result/cache variables:

* PHP_WRITE_STDOUT - Whether 'write()' can write to stdout.
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSourceRuns)
include(CMakePushCheckState)

# On Windows below check succeeds, however PHP implementation has it disabled.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(PHP_WRITE_STDOUT FALSE)
  return()
endif()

# Skip in consecutive configuration phases.
if(DEFINED PHP_WRITE_STDOUT)
  return()
endif()

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

  check_include_files(unistd.h HAVE_UNISTD_H)

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
