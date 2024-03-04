#[=============================================================================[
Check for IPv6 support.

Cache variables:

  HAVE_IPV6
    Whether IPv6 support is enabled.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Checking for IPv6 support")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C "
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <netinet/in.h>

    int main(void) {
      struct sockaddr_in6 s;
      struct in6_addr t = in6addr_any;
      int i = AF_INET6;
      s;
      t.s6_addr[0] = 0;

      return 0;
    }
  " HAVE_IPV6)
cmake_pop_check_state()

if(HAVE_IPV6)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
