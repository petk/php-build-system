#[=============================================================================[
Check for IPv6 support.

Result variables:

* HAVE_IPV6 - Whether IPv6 support is supported and enabled.
#]=============================================================================]

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

  # On some systems, additional library is needed for the in6addr_any variable
  # (from <netinet/in.h>).
  php_search_libraries(
    SOURCE_COMPILES [[
      #include <sys/types.h>
      #include <sys/socket.h>
      #include <netinet/in.h>

      int main(void)
      {
        struct sockaddr_in6 s;
        struct in6_addr t = in6addr_any;
        int i = AF_INET6;
        t.s6_addr[0] = 0;
        (void)s;
        (void)t;
        (void)i;

        return 0;
      }
    ]]
    LIBRARIES
      socket  # Solaris <= 11.3, illumos
      network # Haiku
    RESULT_VARIABLE PHP_HAVE_IPV6
    LIBRARY_VARIABLE PHP_HAVE_IPV6_LIBRARY
    TARGET php_config INTERFACE
  )
cmake_pop_check_state()
set(HAVE_IPV6 ${PHP_HAVE_IPV6})

if(PHP_HAVE_IPV6)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
