#[=============================================================================[
Checks for IPv6 support.

Function: ipv6()

Sets the following variables if IPv6 support is available:
``HAVE_IPV6``
  Defined to 1 if IPv6 support should be enabled.
]=============================================================================]#

include(CheckCSourceCompiles)

function(ipv6)
  message(STATUS "Checking for IPv6 support")

  check_c_source_compiles("
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <netinet/in.h>

    int main() {
      struct sockaddr_in6 s;
      struct in6_addr t = IN6ADDR_ANY_INIT;
      int i = AF_INET6;
      s; t.s6_addr[0] = 0;

      return 0;
    }
  " HAVE_IPV6)
endfunction()

ipv6()
