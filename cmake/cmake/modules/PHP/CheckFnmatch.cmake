#[=============================================================================[
Check for a working POSIX fnmatch() function.

Some versions of Solaris (2.4), SCO, and the GNU C Library have a broken or
incompatible fnmatch. When cross-compiling we only enable it for Linux systems.
Based on the AC_FUNC_FNMATCH Autoconf macro.

TODO: This is obsolescent. See Gnulib's fnmatch-gnu module:
https://www.gnu.org/software/gnulib/MODULES.html#module=fnmatch

Cache variables:

  HAVE_FNMATCH
    Whether fnmatch is a working POSIX variant.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)

message(CHECK_START "Checking for a working POSIX fnmatch() function")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_CROSSCOMPILING)
  check_source_runs(C [[
    #include <fnmatch.h>
    #define y(a, b, c) (fnmatch (a, b, c) == 0)
    #define n(a, b, c) (fnmatch (a, b, c) == FNM_NOMATCH)

    int main(void) {
      return
        (!(y ("a*", "abc", 0)
          && n ("d*/*1", "d/s/1", FNM_PATHNAME)
          && y ("a\\bc", "abc", 0)
          && n ("a\\bc", "abc", FNM_NOESCAPE)
          && y ("*x", ".x", 0)
          && n ("*x", ".x", FNM_PERIOD)
          && 1));
    }
  ]] HAVE_FNMATCH)
elseif(CMAKE_CROSSCOMPILING AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(
    HAVE_FNMATCH 1
    CACHE INTERNAL "Define to 1 if system has a working POSIX fnmatch function."
  )
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_FNMATCH)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
