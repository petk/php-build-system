#[=============================================================================[
Check /dev/poll for Solaris < 10

Result variables:

* HAVE_DEVPOLL
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_DEVPOLL FALSE)

# Skip in consecutive configuration phases.
if(DEFINED PHP_SAPI_FPM_HAS_DEVPOLL)
  if(PHP_SAPI_FPM_HAS_DEVPOLL)
    set(HAVE_DEVPOLL TRUE)
  endif()
  return()
endif()

message(CHECK_START "Checking for /dev/poll")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <stdio.h>
    #include <sys/devpoll.h>

    int main(void)
    {
      int n, dp;
      struct dvpoll dvp;
      dp = 0;
      dvp.dp_fds = NULL;
      dvp.dp_nfds = 0;
      dvp.dp_timeout = 0;
      n = ioctl(dp, DP_POLL, &dvp);
      (void)n;

      return 0;
    }
  ]] PHP_SAPI_FPM_HAS_DEVPOLL)
cmake_pop_check_state()

if(PHP_SAPI_FPM_HAS_DEVPOLL)
  set(HAVE_DEVPOLL TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
