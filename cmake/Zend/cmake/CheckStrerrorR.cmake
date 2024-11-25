#[=============================================================================[
# CheckStrerrorR

Check for `strerror_r()`, and if its a POSIX-compatible or a GNU-specific
version.

## Cache variables

* `HAVE_STRERROR_R`

  Whether `strerror_r()` is available.

* `STRERROR_R_CHAR_P`

  Whether `strerror_r()` returns a `char *` message, otherwise it returns an
  `int` error number.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)

check_symbol_exists(strerror_r "string.h" HAVE_STRERROR_R)

if(NOT HAVE_STRERROR_R)
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_source_compiles(C [[
    #include <string.h>

    int main(void)
    {
      char buf[100];
      char x = *strerror_r (0, buf, sizeof buf);
      char *p = strerror_r (0, buf, sizeof buf);
      return !p || x;
    }
  ]] STRERROR_R_CHAR_P)
cmake_pop_check_state()
