#[=============================================================================[
Check FPM listening queue implementation.

## Cache variables

* `HAVE_LQ_TCP_INFO`

  Whether `TCP_INFO` is present.

* `HAVE_LQ_TCP_CONNECTION_INFO`

  Whether `TCP_CONNECTION_INFO` is present.

* `HAVE_LQ_SO_LISTENQ`

  Whether `SO_LISTENQLEN` and `SO_LISTENQLIMIT` are available as alternative to
  `TCP_INFO` and `TCP_CONNECTION_INFO`.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

message(CHECK_START "Checking FPM listening queue implementation")

cmake_push_check_state(RESET)
  # Requires _DEFAULT_SOURCE, which is enabled by _GNU_SOURCE.
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
  check_source_compiles(C [[
    #include <netinet/tcp.h>

    int main(void)
    {
      struct tcp_info ti;
      int x = TCP_INFO;
      (void)ti;
      (void)x;

      return 0;
    }
  ]] HAVE_LQ_TCP_INFO)
cmake_pop_check_state()

# For macOS.
if(NOT HAVE_LQ_TCP_INFO)
  check_source_compiles(C [[
    #include <netinet/tcp.h>

    int main(void)
    {
      struct tcp_connection_info ti;
      int x = TCP_CONNECTION_INFO;
      (void)ti;
      (void)x;

      return 0;
    }
  ]] HAVE_LQ_TCP_CONNECTION_INFO)
endif()

# For FreeBSD.
if(NOT HAVE_LQ_TCP_INFO AND NOT HAVE_LQ_TCP_INFO)
  check_source_compiles(C [[
    #include <sys/socket.h>

    int main(void)
    {
      int x = SO_LISTENQLIMIT;
      int y = SO_LISTENQLEN;
      (void)x;
      (void)y;

      return 0;
    }
  ]] HAVE_LQ_SO_LISTENQ)
endif()

if(HAVE_LQ_TCP_INFO OR HAVE_LQ_TCP_CONNECTION_INFO OR HAVE_LQ_SO_LISTENQ)
  message(CHECK_PASS "found")
else()
  message(CHECK_FAIL "not found, FPM listening queue is disabled")
endif()
