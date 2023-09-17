#[=============================================================================[
Check for getaddrinfo, should be a better way, but... Also check for working
getaddrinfo.

If successful the module sets the following variables:

HAVE_GETADDRINFO
  Set to 1 if getaddrinfo function is working as expected.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)

message(STATUS "Checking for getaddrinfo")

check_c_source_compiles("
  #include <netdb.h>

  int main() {
    struct addrinfo *g,h;g=&h;getaddrinfo(\"\",\"\",g,&g);
    return 0;
  }
" _have_getaddrinfo)

if(_have_getaddrinfo AND NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    #include <string.h>
    #include <netdb.h>
    #include <sys/types.h>
    #include <string.h>
    #include <stdlib.h>
    #ifndef AF_INET
    # include <sys/socket.h>
    #endif

    int main(void) {
      struct addrinfo *ai, *pai, hints;

      memset(&hints, 0, sizeof(hints));
      hints.ai_flags = AI_NUMERICHOST;

      if (getaddrinfo(\"127.0.0.1\", 0, &hints, &ai) < 0) {
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
  " _have_getaddrinfo)
endif()

if(CMAKE_CROSSCOMPILING)
  string(TOLOWER "${CMAKE_HOST_SYSTEM}" host_os)
  if(${host_os} MATCHES ".*linux.*")
    set(_have_getaddrinfo ON)
  else()
    set(_have_getaddrinfo OFF)
  endif()
endif()

if(_have_getaddrinfo)
  set(HAVE_GETADDRINFO 1 CACHE INTERNAL "Define if you have the getaddrinfo function")
endif()

unset(_have_getaddrinfo)
