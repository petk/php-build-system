#[=============================================================================[
Check if fopencookie() works as expected.

First, the fopencookie() and type cookie_io_functions_t are checked if they are
available. Then check is done whether the 'fopencookie' seeker uses type
off64_t. Since off64_t is non-standard and obsolescent, the standard off_t type
can be used on both 64-bit and 32-bit systems, where the _FILE_OFFSET_BITS=64
can make it behave like off64_t on 32-bit platforms. Since code is in the
transition process to use off_t only, check is left here when using glibc.

Result variables:

* HAVE_FOPENCOOKIE
* COOKIE_SEEKER_USES_OFF64_T
#]=============================================================================]

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakePushCheckState)

set(COOKIE_SEEKER_USES_OFF64_T FALSE)
set(HAVE_FOPENCOOKIE FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(fopencookie stdio.h PHP_HAVE_FOPENCOOKIE)
cmake_pop_check_state()

if(NOT PHP_HAVE_FOPENCOOKIE)
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  set(CMAKE_EXTRA_INCLUDE_FILES "stdio.h")
  check_type_size("cookie_io_functions_t" PHP_COOKIE_IO_FUNCTIONS_T)
cmake_pop_check_state()

if(NOT HAVE_PHP_COOKIE_IO_FUNCTIONS_T)
  return()
endif()

set(HAVE_FOPENCOOKIE TRUE)

# Skip in consecutive configuration phases.
if(DEFINED PHP_COOKIE_SEEKER_USES_OFF64_T)
  set(COOKIE_SEEKER_USES_OFF64_T ${PHP_COOKIE_SEEKER_USES_OFF64_T})
  return()
endif()

# GNU C library can have a different seeker definition using off64_t.
message(CHECK_START "Checking whether fopencookie seeker uses off64_t")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C [[
    #include <stdio.h>
    #include <stdlib.h>

    struct cookiedata {
      off64_t pos;
    };

    ssize_t reader(void *cookie, char *buffer, size_t size)
    {
      (void)cookie;
      (void)buffer;
      return size;
    }

    ssize_t writer(void *cookie, const char *buffer, size_t size)
    {
      (void)cookie;
      (void)buffer;
      return size;
    }

    int closer(void *cookie)
    {
      (void)cookie;
      return 0;
    }

    int seeker(void *cookie, off64_t *position, int whence)
    {
      ((struct cookiedata*)cookie)->pos = *position;
      (void)whence;
      return 0;
    }

    cookie_io_functions_t funcs = {reader, writer, seeker, closer};

    int main(void)
    {
      struct cookiedata g = { 0 };
      FILE *fp = fopencookie(&g, "r", funcs);

      if (fp && fseek(fp, 8192, SEEK_SET) == 0 && g.pos == 8192) {
        return 0;
      }

      return 1;
    }
  ]] PHP_COOKIE_SEEKER_USES_OFF64_T)
cmake_pop_check_state()

if(PHP_COOKIE_SEEKER_USES_OFF64_T)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

set(COOKIE_SEEKER_USES_OFF64_T ${PHP_COOKIE_SEEKER_USES_OFF64_T})
