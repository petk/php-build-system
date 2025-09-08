#[=============================================================================[
Check for IPv6 support.

Result variables:

* HAVE_IPV6 - Whether IPv6 support is supported and enabled.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

set(HAVE_IPV6 FALSE)

message(CHECK_START "Checking for IPv6 support")

if(NOT PHP_IPV6)
  message(CHECK_FAIL "no")
  return()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  message(CHECK_PASS "yes")
  set(HAVE_IPV6 TRUE)
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  # This check requires additional system library on some systems to link and
  # use struct sockaddr_in6. Mostly, C library is sufficient (Solaris 11.4...).
  php_search_libraries(
    socket
    HEADERS
      sys/socket.h
      winsock2.h
    LIBRARIES
      socket  # Solaris <= 11.3, illumos
      network # Haiku
      ws2_32  # Windows
    VARIABLE PHP_HAVE_SOCKET
    LIBRARY_VARIABLE PHP_HAVE_SOCKET_LIBRARY
    TARGET php_config INTERFACE
  )

  list(APPEND CMAKE_REQUIRED_LIBRARIES ${PHP_HAVE_SOCKET_LIBRARY})

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
  ]] PHP_HAVE_IPV6)
cmake_pop_check_state()
set(HAVE_IPV6 ${PHP_HAVE_IPV6})

if(PHP_HAVE_IPV6)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
