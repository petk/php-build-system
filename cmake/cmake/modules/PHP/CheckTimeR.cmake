#[=============================================================================[
Check type of reentrant time-related functions. Type can be: irix, hpux or
POSIX.

The module sets the following variables:

PHP_HPUX_TIME_R
  Set to 1 if HP-UX 10.x is used.
PHP_IRIX_TIME_R
  Set to 1 if IRIX-style functions are used.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking for type of reentrant time-related functions")

if(NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    #include <time.h>

    int main(void) {
      char buf[27];
      struct tm t;
      time_t old = 0;
      int r, s;

      s = gmtime_r(&old, &t);
      r = (int) asctime_r(&t, buf, 26);
      if (r == s && s == 0) return (0);

      return (1);
    }
  " _time_r_is_hpux)

  if(NOT _time_r_is_hpux)
    check_c_source_runs("
      #include <time.h>

      int main(void) {
        struct tm t, *s;
        time_t old = 0;
        char buf[27], *p;

        s = gmtime_r(&old, &t);
        p = asctime_r(&t, buf, 26);
        if (p == buf && s == &t) return (0);

        return (1);
      }
    " _time_r_is_irix)

    if(_time_r_is_irix)
      set(PHP_IRIX_TIME_R 1 CACHE INTERNAL "Whether you have IRIX-style functions")
    endif()
  else()
    set(PHP_HPUX_TIME_R 1 CACHE INTERNAL "Whether you have HP-UX 10.x")
  endif()
endif()
