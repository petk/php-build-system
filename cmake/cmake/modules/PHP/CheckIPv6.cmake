#[=============================================================================[
Check for IPv6 support.

Module sets the following variables if IPv6 support is available:

HAVE_IPV6
  Set to true if IPv6 support is be enabled.
]=============================================================================]#

include(CheckCSourceCompiles)

function(_php_check_ipv6)
  message(STATUS "Checking for IPv6 support")

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
endfunction()

_php_check_ipv6()
