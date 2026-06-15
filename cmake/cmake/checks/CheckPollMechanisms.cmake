#[=============================================================================[
Check for polling mechanisms.

Result variables:

* HAVE_EPOLL - Whether system has working epoll.
* HAVE_EPOLL_PWAIT2 - Whether system has epoll_pwait2() function.
* HAVE_KQUEUE - Whether system has working kqueue.
* HAVE_EVENT_PORTS - Whether event ports are available.
#]=============================================================================]

include(CheckSourceCompiles)
include(CheckSymbolExists)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_EPOLL FALSE)
  set(HAVE_EPOLL_PWAIT2 FALSE)
  set(HAVE_KQUEUE FALSE)
  set(HAVE_EVENT_PORTS FALSE)

  return()
endif()

message(CHECK_START "Checking for polling mechanisms")

check_source_compiles(
  C
  [[
    #include <sys/epoll.h>

    int main(void)
    {
      int fd = epoll_create(1);
      return fd;
    }
  ]]
  PHP_HAVE_EPOLL
)
set(HAVE_EPOLL ${PHP_HAVE_EPOLL})

if(PHP_HAVE_EPOLL)
  check_symbol_exists(epoll_pwait2 sys/epoll.h PHP_HAVE_EPOLL_PWAIT2)
  set(HAVE_EPOLL_PWAIT2 ${PHP_HAVE_EPOLL_PWAIT2})
endif()

check_source_compiles(
  C
  [[
    #include <sys/event.h>
    #include <sys/time.h>

    int main(void)
    {
      int kq = kqueue();
      return kq;
    }
  ]]
  PHP_HAVE_KQUEUE
)
set(HAVE_KQUEUE ${PHP_HAVE_KQUEUE})

check_source_compiles(
  C
  [[
    #include <port.h>

    int main(void)
    {
      int port = port_create();
      return port;
    }
  ]]
  PHP_HAVE_EVENT_PORTS
)
set(HAVE_EVENT_PORTS ${PHP_HAVE_EVENT_PORTS})

message(CHECK_PASS "done")
