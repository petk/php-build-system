#[=============================================================================[
Check epoll.

Result variables:

* HAVE_EPOLL
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_SAPI_FPM_HAVE_EPOLL)
  message(CHECK_START "Checking for epoll")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
      #include <sys/epoll.h>

      int main(void)
      {
        int epollfd;
        struct epoll_event e;

        epollfd = epoll_create(1);
        if (epollfd < 0) {
          return 1;
        }

        e.events = EPOLLIN | EPOLLET;
        e.data.fd = 0;

        if (epoll_ctl(epollfd, EPOLL_CTL_ADD, 0, &e) == -1) {
          return 1;
        }

        e.events = 0;
        if (epoll_wait(epollfd, &e, 1, 1) < 0) {
          return 1;
        }

        return 0;
      }
    ]] PHP_SAPI_FPM_HAVE_EPOLL)
  cmake_pop_check_state()

  if(PHP_SAPI_FPM_HAVE_EPOLL)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_EPOLL ${PHP_SAPI_FPM_HAVE_EPOLL})
