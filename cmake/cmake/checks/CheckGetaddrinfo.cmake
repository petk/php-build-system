#[=============================================================================[
Check whether getaddrinfo() function is working as expected.

Result variables:

* HAVE_GETADDRINFO
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

set(HAVE_GETADDRINFO FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_GETADDRINFO TRUE)
  target_link_libraries(php_config INTERFACE ws2_32)
  return()
endif()

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
  LIBRARY_VARIABLE library
)
if(library)
  target_link_libraries(php_config INTERFACE ${library})
endif()

if(DEFINED PHP_HAS_GETADDRINFO)
  if(PHP_HAS_GETADDRINFO)
    set(HAVE_GETADDRINFO TRUE)
  endif()
  return()
endif()

message(CHECK_START "Checking whether getaddrinfo() works")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  if(library)
    set(CMAKE_REQUIRED_LIBRARIES ${library})
  endif()

  if(
    NOT DEFINED PHP_HAS_GETADDRINFO_EXITCODE
    AND CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
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
  set(HAVE_GETADDRINFO TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
