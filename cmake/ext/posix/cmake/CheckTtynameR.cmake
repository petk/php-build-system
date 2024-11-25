#[=============================================================================[
# CheckTtynameR

Check `ttyname_r()`.

On Solaris/illumos `ttyname_r()` works only with larger buffers (>= 128),
unlike, for example, on Linux and other systems, where buffer size can be any
`size_t` size, also < 128. PHP code uses `ttyname_r()` with large buffers, so it
wouldn't be necessary to check small buffers but the run check below is kept for
brevity.

On modern systems a simpler check is sufficient in the future:

```cmake
check_symbol_exists(ttyname_r unistd.h HAVE_TTYNAME_R)
```

## Cache variables

* `HAVE_TTYNAME_R`

  Whether `ttyname_r()` works as expected.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckPrototypeDefinition)
include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

message(CHECK_START "Checking for working ttyname_r()")

cmake_push_check_state(RESET)
  cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
  if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
    set(CMAKE_REQUIRED_QUIET TRUE)
  endif()

  # To get the standard declaration with return type int instead of the char *:
  # - _POSIX_PTHREAD_SEMANTICS is needed on Solaris<=11.3 and illumos
  # - _DARWIN_C_SOURCE on older Mac OS X 10.4
  set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

  check_prototype_definition(
    ttyname_r
    "int ttyname_r(int fd, char *buf, size_t buflen)"
    "0"
    "unistd.h"
    _HAVE_TTYNAME_R
  )

  if(NOT _HAVE_TTYNAME_R)
    message(CHECK_FAIL "no (non-standard declaration)")
    cmake_pop_check_state()
    return()
  endif()

  if(
    NOT DEFINED HAVE_TTYNAME_R_EXITCODE
    AND CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
  )
    set(HAVE_TTYNAME_R_EXITCODE 0)
  endif()

  # PHP Autotools-based build system check uses a different return below due
  # to Autoconf's configure using the file descriptor 0 which results in an
  # error. The file descriptor 0 with CMake script execution is available and
  # doesn't result in an error when calling ttyname_r().
  check_source_runs(C [[
    #include <unistd.h>

    int main(void)
    {
      #ifdef _SC_TTY_NAME_MAX
        int buflen = sysconf(_SC_TTY_NAME_MAX);
      #else
        int buflen = 32; /* Small buffers < 128 */
      #endif
      if (buflen < 1) {
        buflen = 32;
      }
      char buf[buflen];

      return ttyname_r(0, buf, buflen) ? 1 : 0;
    }
  ]] HAVE_TTYNAME_R)
  if(HAVE_TTYNAME_R)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no (posix_ttyname() will be thread-unsafe)")
  endif()
cmake_pop_check_state()
