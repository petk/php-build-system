#[=============================================================================[
Check whether getaddrinfo() function is working as expected.
#]=============================================================================]

include(PHP/SearchLibraries)

# On Windows, getaddrinfo() and its implementation in PHP are supported.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(PHP_HAVE_GETADDRINFO TRUE)
  set(PHP_HAVE_GETADDRINFO_LIBRARY ws2_32)
endif()

if(
  CMAKE_CROSSCOMPILING
  AND NOT CMAKE_CROSSCOMPILING_EMULATOR
  AND NOT DEFINED PHP_HAVE_GETADDRINFO_EXITCODE
  AND CMAKE_SYSTEM_NAME MATCHES "^(Linux|Midipix)$"
)
  set(PHP_HAVE_GETADDRINFO_EXITCODE 0)
endif()

# The getaddrinfo() is mostly in C library (Solaris 11.4, illumos...)
php_search_libraries(
  SOURCE_RUNS [[
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
  ]]
  HEADERS
    netdb.h
    ws2tcpip.h
  LIBRARIES
    socket  # Solaris <= 11.3
    network # Haiku
    ws2_32  # Windows
  RESULT_VARIABLE PHP_HAVE_GETADDRINFO
  LIBRARY_VARIABLE PHP_HAVE_GETADDRINFO_LIBRARY
  TARGET php_config INTERFACE
)

set(HAVE_GETADDRINFO "${PHP_HAVE_GETADDRINFO}")
