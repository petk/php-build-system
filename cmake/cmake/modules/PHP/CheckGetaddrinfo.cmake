#[=============================================================================[
# PHP/CheckGetaddrinfo

Check for working `getaddrinfo()`.

## Cache variables

* `HAVE_GETADDRINFO`

  Whether `getaddrinfo()` function is working as expected.

IMPORTED target:

* `PHP::CheckGetaddrinfoLibrary`

  If there is additional library to be linked for using `getaddrinfo()`.

## Usage

```cmake
# CMakeLists.txt
include(PHP/CheckGetaddrinfo)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

message(CHECK_START "Checking for getaddrinfo()")

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
  LIBRARY_VARIABLE libraryForGetaddrinfo
)
if(libraryForGetaddrinfo)
  add_library(PHP::CheckGetaddrinfoLibrary INTERFACE IMPORTED GLOBAL)

  target_link_libraries(
    PHP::CheckGetaddrinfoLibrary
    INTERFACE
      ${libraryForGetaddrinfo}
  )
endif()

# If the variable HAVE_GETADDRINFO has been overridden the module stops here.
# For example, on Windows.
if(HAVE_GETADDRINFO)
  message(CHECK_PASS "yes (cached)")
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  if(TARGET PHP::CheckGetaddrinfoLibrary)
    set(CMAKE_REQUIRED_LIBRARIES PHP::CheckGetaddrinfoLibrary)
  endif()

  if(
    NOT DEFINED HAVE_GETADDRINFO_EXITCODE
    AND CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
    AND CMAKE_SYSTEM_NAME STREQUAL "Linux"
  )
    set(HAVE_GETADDRINFO_EXITCODE 0)
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
  ]] HAVE_GETADDRINFO)
cmake_pop_check_state()

if(HAVE_GETADDRINFO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
