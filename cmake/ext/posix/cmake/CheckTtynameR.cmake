#[=============================================================================[
This check determines whether the ttyname_r() is present and works as expected.
On Solaris/illumos ttyname_r() works only with larger buffers (>= 128), unlike,
for example, on Linux and other systems, where buffer size can be any 'size_t'
size, also < 128. PHP code uses ttyname_r() with large buffers, so it wouldn't
be necessary to check small buffers but the run check below is kept for brevity.

On modern systems a simpler check is sufficient in the future:

  check_symbol_exists(ttyname_r unistd.h <result-var>)
#]=============================================================================]

include(CheckPrototypeDefinition)
include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

function(_php_ext_posix_check_ttyname_r result)
  set(${result} FALSE)

  if(PHP_EXT_POSIX_HAS_TTYNAME_R)
    set(${result} TRUE)
    return(PROPAGATE ${result})
  endif()

  if(DEFINED PHP_EXT_POSIX_HAS_TTYNAME_R_SYMBOL)
    return(PROPAGATE ${result})
  endif()

  message(CHECK_START "Checking for working ttyname_r()")

  cmake_push_check_state(RESET)
    cmake_language(GET_MESSAGE_LOG_LEVEL log_level)
    if(NOT log_level MATCHES "^(VERBOSE|DEBUG|TRACE)$")
      set(CMAKE_REQUIRED_QUIET TRUE)
    endif()

    # To get the standard declaration with return type int instead of the
    # 'char *':
    # - _POSIX_PTHREAD_SEMANTICS is needed on Solaris<=11.3 and illumos
    # - _DARWIN_C_SOURCE on older Mac OS X 10.4
    set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)

    check_prototype_definition(
      ttyname_r
      "int ttyname_r(int fd, char *buf, size_t buflen)"
      "0"
      "unistd.h"
      PHP_EXT_POSIX_HAS_TTYNAME_R_SYMBOL
    )

    if(NOT PHP_EXT_POSIX_HAS_TTYNAME_R_SYMBOL)
      message(CHECK_FAIL "no (non-standard declaration)")
      cmake_pop_check_state()
      return(PROPAGATE ${result})
    endif()

    if(
      CMAKE_CROSSCOMPILING
      AND NOT CMAKE_CROSSCOMPILING_EMULATOR
      AND NOT DEFINED PHP_EXT_POSIX_HAS_TTYNAME_R_EXITCODE
    )
      set(PHP_EXT_POSIX_HAS_TTYNAME_R_EXITCODE 0)
    endif()

    # PHP Autotools-based build system check uses a different return below due
    # to Autoconf's configure using the file descriptor 0 which results in an
    # error. The file descriptor 0 with CMake script execution is available
    # and doesn't result in an error when calling ttyname_r().
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
    ]] PHP_EXT_POSIX_HAS_TTYNAME_R)
  cmake_pop_check_state()

  if(PHP_EXT_POSIX_HAS_TTYNAME_R)
    set(${result} TRUE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no (posix_ttyname() will be thread-unsafe)")
  endif()

  return(PROPAGATE ${result})
endfunction()

_php_ext_posix_check_ttyname_r(HAVE_TTYNAME_R)
