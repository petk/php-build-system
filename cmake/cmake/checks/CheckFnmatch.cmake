#[=============================================================================[
Check for a working POSIX 'fnmatch()' function.

This check is based on the 'AC_FUNC_FNMATCH' Autoconf macro. Some versions of
Solaris (2.4), SCO, and the GNU C Library have a broken or incompatible fnmatch.
In cross-compilation it is checked with the CheckSymbolExists module instead
and assumed to have a POSIX-compatible implementation.

Gnulib provides also fnmatch-gnu module:
https://www.gnu.org/software/gnulib/MODULES.html#module=fnmatch

Result variables:

* HAVE_FNMATCH
#]=============================================================================]

# PHP has fnmatch() emulation implemented on Windows.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_FNMATCH TRUE)
  return()
endif()

# Skip in consecutive configuration phases or if overridden.
if(DEFINED PHP_HAVE_FNMATCH)
  set(HAVE_FNMATCH ${PHP_HAVE_FNMATCH})
  return()
endif()

include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

message(CHECK_START "Checking for a working POSIX fnmatch() function")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  if(
    CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
    AND NOT DEFINED PHP_HAVE_FNMATCH_EXITCODE
  )
    check_symbol_exists(fnmatch fnmatch.h PHP_HAVE_FNMATCH)
  endif()

  check_source_runs(C [[
    #include <fnmatch.h>
    #define y(a, b, c) (fnmatch (a, b, c) == 0)
    #define n(a, b, c) (fnmatch (a, b, c) == FNM_NOMATCH)

    int main(void)
    {
      return
        (!(y ("a*", "abc", 0)
          && n ("d*/*1", "d/s/1", FNM_PATHNAME)
          && y ("a\\bc", "abc", 0)
          && n ("a\\bc", "abc", FNM_NOESCAPE)
          && y ("*x", ".x", 0)
          && n ("*x", ".x", FNM_PERIOD)
          && 1));
    }
  ]] PHP_HAVE_FNMATCH)
cmake_pop_check_state()

if(PHP_HAVE_FNMATCH)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

set(HAVE_FNMATCH ${PHP_HAVE_FNMATCH})
