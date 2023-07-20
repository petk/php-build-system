#[=============================================================================[
Checks for IPv6 support.

Function: ipv6()

Command line option: -DIPV6
]=============================================================================]#

include(CheckCSourceRuns)

function(ipv6)
  option(IPV6 "Whether to enable IPv6 support" ON)
  message(STATUS "Checking for IPv6 support")

  if(NOT IPV6)
    message(STATUS "IPv6 support not enabled")
    return()
  endif()

  check_c_source_runs("
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
  " IPV6_SUPPORT)

  if(NOT IPV6_SUPPORT)
    message(STATUS "IPv6 support not enabled")
    return()
  endif()

  set(HAVE_IPV6 1 CACHE STRING "Whether to enable IPv6 support")

  message(STATUS "IPv6 support enabled")
endfunction()
