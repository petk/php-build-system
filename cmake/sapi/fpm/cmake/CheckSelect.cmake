#[=============================================================================[
Check select.

Result variables:

* HAVE_SELECT
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_SELECT FALSE)

# Skip in consecutive configuration phases.
if(DEFINED PHP_SAPI_FPM_HAS_SELECT)
  if(PHP_SAPI_FPM_HAS_SELECT)
    set(HAVE_SELECT TRUE)
  endif()
  return()
endif()

message(CHECK_START "Checking for select")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C [[
    /* According to POSIX.1-2001 */
    #include <sys/select.h>

    /* According to earlier standards */
    #include <sys/time.h>
    #include <sys/types.h>
    #include <unistd.h>

    int main(void)
    {
      fd_set fds;
      struct timeval t;
      t.tv_sec = 0;
      t.tv_usec = 42;
      FD_ZERO(&fds);
      /* 0 -> STDIN_FILENO */
      FD_SET(0, &fds);
      select(FD_SETSIZE, &fds, NULL, NULL, &t);

      return 0;
    }
  ]] PHP_SAPI_FPM_HAS_SELECT)
cmake_pop_check_state()

if(PHP_SAPI_FPM_HAS_SELECT)
  set(HAVE_SELECT TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
