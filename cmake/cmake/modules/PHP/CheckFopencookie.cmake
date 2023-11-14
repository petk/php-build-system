#[=============================================================================[
Check if fopencookie() is working as expected.

Cache variables:

  HAVE_FOPENCOOKIE
    Whether fopencookie() and cookie_io_functions_t are available.
  COOKIE_SEEKER_USES_OFF64_T
    Whether a newer seeker definition for fopencookie() is available.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(fopencookie "stdio.h" _have_fopencookie)
cmake_pop_check_state()

if(NOT _have_fopencookie)
  return()
endif()

# glibcs (since 2.1.2?) have a type called cookie_io_functions_t.
message(CHECK_START "Checking whether cookie_io_functions_t is available")

check_c_source_compiles("
  #define _GNU_SOURCE
  #include <stdio.h>

  int main(void) {
    cookie_io_functions_t cookie;
    return 0;
  }
" HAVE_FOPENCOOKIE)

if(NOT HAVE_FOPENCOOKIE)
  message(CHECK_FAIL "no")
  return()
else()
  message(CHECK_PASS "yes")
endif()

# Newer glibcs have a different seeker definition.
message(
  CHECK_START
  "Checking whether newer fopencookie seeker definition is available"
)

if(CMAKE_CROSSCOMPILING AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  set(
    COOKIE_SEEKER_USES_OFF64_T 1
    CACHE INTERNAL "Whether newer fopencookie seeker definition is available"
  )
else()
  check_c_source_runs("
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>

    struct cookiedata {
      off64_t pos;
    };

    ssize_t reader(void *cookie, char *buffer, size_t size) {
      return size;
    }

    ssize_t writer(void *cookie, const char *buffer, size_t size) {
      return size;
    }

    int closer(void *cookie) {
      return 0;
    }

    int seeker(void *cookie, off64_t *position, int whence) {
      ((struct cookiedata*)cookie)->pos = *position;

      return 0;
    }

    cookie_io_functions_t funcs = {reader, writer, seeker, closer};

    int main(void) {
      struct cookiedata g = { 0 };
      FILE *fp = fopencookie(&g, \"r\", funcs);

      if (fp && fseek(fp, 8192, SEEK_SET) == 0 && g.pos == 8192)
        return 0;

      return 1;
    }
  " COOKIE_SEEKER_USES_OFF64_T)
endif()

if(CMAKE_CROSSCOMPILING AND COOKIE_SEEKER_USES_OFF64_T)
  message(CHECK_PASS "yes (cross-compiling)")
elseif(COOKIE_SEEKER_USES_OFF64_T)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
