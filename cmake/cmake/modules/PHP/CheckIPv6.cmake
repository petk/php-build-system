#[=============================================================================[
# PHP/CheckIPv6

Check for IPv6 support.

## Result variables

* `HAVE_IPV6`

  Whether IPv6 support is supported and enabled.

## Usage

```cmake
# CMakeLists.txt
include(PHP/CheckIPv6)
```
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_IPV6 FALSE)

message(CHECK_START "Checking for IPv6 support")

if(NOT PHP_IPV6)
  message(CHECK_FAIL "no")
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C [[
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <netinet/in.h>

    int main(void)
    {
      struct sockaddr_in6 s;
      struct in6_addr t = in6addr_any;
      int i = AF_INET6;
      (void)s;
      t.s6_addr[0] = 0;
      (void)i;

      return 0;
    }
  ]] PHP_HAS_IPV6)
cmake_pop_check_state()

if(PHP_HAS_IPV6)
  set(HAVE_IPV6 TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
