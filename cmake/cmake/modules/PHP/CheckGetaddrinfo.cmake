#[=============================================================================[
Check for working getaddrinfo().

Cache variables:

  HAVE_GETADDRINFO
    Whether getaddrinfo() function is working as expected.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CheckSourceRuns)

message(CHECK_START "Checking for getaddrinfo()")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_source_compiles(C [[
  #include <netdb.h>

  int main(void) {
    struct addrinfo *g,h;
    g = &h;
    getaddrinfo("", "", g, &g);

    return 0;
  }
]] _have_getaddrinfo)

if(_have_getaddrinfo)
  if(NOT CMAKE_CROSSCOMPILING)
    check_source_runs(C [[
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
    ]] HAVE_GETADDRINFO)
  else()
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(
        HAVE_GETADDRINFO 1
        CACHE INTERNAL "Define if you have the getaddrinfo() function"
      )
    endif()
  endif()
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_GETADDRINFO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
