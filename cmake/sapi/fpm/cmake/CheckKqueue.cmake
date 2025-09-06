#[=============================================================================[
Check for kqueue.

Result variables:

* HAVE_KQUEUE
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_SAPI_FPM_HAVE_KQUEUE)
  message(CHECK_START "Checking for kqueue")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
      #include <sys/types.h>
      #include <sys/event.h>
      #include <sys/time.h>

      int main(void)
      {
        int kfd;
        struct kevent k;
        kfd = kqueue();
        /* 0 -> STDIN_FILENO */
        EV_SET(&k, 0, EVFILT_READ , EV_ADD | EV_CLEAR, 0, 0, NULL);
        (void)kfd;

        return 0;
      }
    ]] PHP_SAPI_FPM_HAVE_KQUEUE)
  cmake_pop_check_state()

  if(PHP_SAPI_FPM_HAVE_KQUEUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_KQUEUE ${PHP_SAPI_FPM_HAVE_KQUEUE})
