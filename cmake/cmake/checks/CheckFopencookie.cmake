#[=============================================================================[
Check if 'fopencookie()' works as expected.

Module first checks if 'fopencookie()' and type 'cookie_io_functions_t' are
available. Then it checks whether the 'fopencookie' seeker uses type 'off64_t'.
Since 'off64_t' is non-standard and obsolescent, the standard 'off_t' type can
be used on both 64-bit and 32-bit systems, where the '_FILE_OFFSET_BITS=64' can
make it behave like 'off64_t' on 32-bit. Since code is in the transition process
to use 'off_t' only, check is left here when using glibc.

Result variables:

* HAVE_FOPENCOOKIE - Whether 'fopencookie()' and 'cookie_io_functions_t' are
  available.
* COOKIE_SEEKER_USES_OFF64_T - Whether 'fopencookie' seeker uses the 'off64_t'
  type.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
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
  check_symbol_exists(fopencookie stdio.h PHP_HAS_FOPENCOOKIE)
cmake_pop_check_state()

if(NOT PHP_HAS_FOPENCOOKIE)
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
if(DEFINED PHP_HAS_COOKIE_SEEKER_OFF64_T)
  if(PHP_HAS_COOKIE_SEEKER_OFF64_T)
    set(COOKIE_SEEKER_USES_OFF64_T TRUE)
  endif()
  return()
endif()

# GNU C library can have a different seeker definition using off64_t.
message(CHECK_START "Checking whether fopencookie seeker uses off64_t")

if(
  NOT DEFINED PHP_HAS_COOKIE_SEEKER_OFF64_T_EXITCODE
  AND CMAKE_CROSSCOMPILING
  AND NOT CMAKE_CROSSCOMPILING_EMULATOR
  AND CMAKE_SYSTEM_NAME STREQUAL "Linux"
  AND PHP_C_STANDARD_LIBRARY STREQUAL "glibc"
)
  set(PHP_HAS_COOKIE_SEEKER_OFF64_T_EXITCODE 0)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  check_source_runs(C [[
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
  ]] PHP_HAS_COOKIE_SEEKER_OFF64_T)
cmake_pop_check_state()

if(PHP_HAS_COOKIE_SEEKER_OFF64_T)
  set(COOKIE_SEEKER_USES_OFF64_T TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
