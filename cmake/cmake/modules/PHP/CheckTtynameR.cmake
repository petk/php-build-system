#[=============================================================================[
Check ttyname_r().

Autoconf PHP build check uses a different return due to Autoconf's configure
using the file descriptor 0 which results below in an error. The file descriptor
0 with CMake script execution is available and doesn't result in an error when
calling ttyname_r().

TODO:
- The ttyname_r return value doesn't behave the same on Solaris Autoconf/CMake.

Cache variables:

  HAVE_TTYNAME_R
    Whether ttyname_r() works as expected.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking for working ttyname_r()")

if(CMAKE_CROSSCOMPILING)
  message(
    CHECK_FAIL
    "no (cross-compiling), posix_ttyname() will be thread-unsafe"
  )
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    # To get the declaration conforming to standards (with return type int), on
    # Solaris <=10, _POSIX_PTHREAD_SEMANTICS is required, and on macOS
    # _DARWIN_C_SOURCE.
    set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

    check_symbol_exists(ttyname_r unistd.h _HAVE_TTYNAME_R)

    if(_HAVE_TTYNAME_R)
      check_source_runs(C [[
        #include <unistd.h>

        int main(int argc, char *argv[]) {
          char buf[64];

          return ttyname_r(0, buf, 64) ? 1 : 0;
        }
      ]] HAVE_TTYNAME_R)
    endif()
  cmake_pop_check_state()

  if(HAVE_TTYNAME_R)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no (posix_ttyname() will be thread-unsafe)")
  endif()
endif()
