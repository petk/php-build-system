#[=============================================================================[
Check whether getaddrinfo() function is working as expected.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

# The getaddrinfo() is mostly in C library (Solaris 11.4, illumos...)
php_search_libraries(
  getaddrinfo
  HEADERS
    netdb.h
    ws2tcpip.h
  LIBRARIES
    socket  # Solaris <= 11.3
    network # Haiku
    ws2_32  # Windows
  VARIABLE PHP_HAS_GETADDRINFO_SYMBOL
  LIBRARY_VARIABLE PHP_HAS_GETADDRINFO_LIBRARY
)

if(PHP_HAS_GETADDRINFO_SYMBOL AND NOT DEFINED PHP_HAS_GETADDRINFO)
  message(CHECK_START "Checking whether getaddrinfo() works")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    if(PHP_HAS_GETADDRINFO_LIBRARY)
      set(CMAKE_REQUIRED_LIBRARIES ${PHP_HAS_GETADDRINFO_LIBRARY})
    endif()

    if(
      CMAKE_CROSSCOMPILING
      AND NOT CMAKE_CROSSCOMPILING_EMULATOR
      AND NOT DEFINED PHP_HAS_GETADDRINFO_EXITCODE
      AND CMAKE_SYSTEM_NAME MATCHES "^(Linux|Midipix)$"
    )
      set(PHP_HAS_GETADDRINFO_EXITCODE 0)
    endif()

    check_source_runs(C [[
      #include <netdb.h>
      #include <sys/types.h>
      #include <string.h>
      #include <stdlib.h>
      #ifndef AF_INET
      # include <sys/socket.h>
      #endif

      int main(void)
      {
        struct addrinfo *ai, *pai, hints;

        memset(&hints, 0, sizeof(hints));
        hints.ai_flags = AI_NUMERICHOST;

        if (getaddrinfo("127.0.0.1", 0, &hints, &ai) < 0) {
          return 1;
        }

        if (ai == 0) {
          return 1;
        }

        pai = ai;

        while (pai) {
          if (pai->ai_family != AF_INET) {
            /* 127.0.0.1/NUMERICHOST should only resolve ONE way */
            return 1;
          }
          if (pai->ai_addr->sa_family != AF_INET) {
            /* 127.0.0.1/NUMERICHOST should only resolve ONE way */
            return 1;
          }
          pai = pai->ai_next;
        }
        freeaddrinfo(ai);

        return 0;
      }
    ]] PHP_HAS_GETADDRINFO)
  cmake_pop_check_state()

  if(PHP_HAS_GETADDRINFO)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

if(PHP_HAS_GETADDRINFO AND PHP_HAS_GETADDRINFO_LIBRARY)
  target_link_libraries(php_config INTERFACE ${PHP_HAS_GETADDRINFO_LIBRARY})
endif()

set(HAVE_GETADDRINFO "${PHP_HAS_GETADDRINFO}")
