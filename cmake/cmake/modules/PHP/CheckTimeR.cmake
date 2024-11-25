#[=============================================================================[
# PHP/CheckTimeR

Check type of reentrant time-related functions. Type can be: irix, hpux or
POSIX.

## Cache variables

* `PHP_HPUX_TIME_R`

  Whether HP-UX 10.x is used.

* `PHP_IRIX_TIME_R`

  Whether IRIX-style functions are used.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)

message(CHECK_START "Checking type of reentrant time-related functions")

check_source_runs(C [[
  #include <time.h>

  int main(void)
  {
    char buf[27];
    struct tm t;
    time_t old = 0;
    int r, s;

    s = gmtime_r(&old, &t);
    r = (int) asctime_r(&t, buf, 26);
    if (r == s && s == 0) return (0);

    return (1);
  }
]] PHP_HPUX_TIME_R)

if(NOT PHP_HPUX_TIME_R)
  check_source_runs(C [[
    #include <time.h>

    int main(void)
    {
      struct tm t, *s;
      time_t old = 0;
      char buf[27], *p;

      s = gmtime_r(&old, &t);
      p = asctime_r(&t, buf, 26);
      if (p == buf && s == &t) return (0);

      return (1);
    }
  ]] PHP_IRIX_TIME_R)
endif()

if(PHP_HPUX_TIME_R)
  message(CHECK_PASS "HP-UX")
elseif(PHP_IRIX_TIME_R)
  message(CHECK_PASS "IRIX")
else()
  message(CHECK_PASS "POSIX")
endif()
