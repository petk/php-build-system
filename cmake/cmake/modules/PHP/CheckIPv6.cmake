#[=============================================================================[
Check for IPv6 support.

Cache variables:

  HAVE_IPV6
    Whether IPv6 support is enabled.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckCSourceCompiles)

message(CHECK_START "Checking for IPv6 support")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
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

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_IPV6)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
