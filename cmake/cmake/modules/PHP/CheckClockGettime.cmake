#[=============================================================================[
Check for clock_get*time().

Cache variables:

  HAVE_CLOCK_GETTIME
    Whether clock_gettime() is present.
  HAVE_CLOCK_GET_TIME
    Whether clock_get_time() is present.

Interface library:

  PHP::CheckClock
    If there are additional libraries that need to be linked.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking for clock_gettime")

check_c_source_compiles("
  #include <time.h>

  int main(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return 0;
  }
" _have_clock_gettime_without_rt)

if(NOT _have_clock_gettime_without_rt)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES rt)
    check_c_source_compiles("
      #include <time.h>

      int main(void) {
        struct timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        return 0;
      }
    " _have_clock_gettime_with_rt)
  cmake_pop_check_state()

  if(_have_clock_gettime_with_rt)
    add_library(php_check_clock_gettime INTERFACE)
    add_library(PHP::CheckClockGettime ALIAS php_check_clock_gettime)

    target_link_libraries(php_check_clock_gettime INTERFACE rt)
  endif()
endif()

if(_have_clock_gettime_without_rt OR _have_clock_gettime_with_rt)
  set(HAVE_CLOCK_GETTIME 1 CACHE INTERNAL "Whether clock_gettime is present")
  message(CHECK_PASS "yes")
else()
  message(CHECK_PASS "no")
endif()

if(NOT HAVE_CLOCK_GETTIME)
  message(CHECK_START "Checking for clock_get_time")

  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      #include <mach/mach.h>
      #include <mach/clock.h>
      #include <mach/mach_error.h>

      int main(void) {
        kern_return_t ret; clock_serv_t aClock; mach_timespec_t aTime;
        ret = host_get_clock_service(mach_host_self(), REALTIME_CLOCK, &aClock);

        if (ret != KERN_SUCCESS) {
          return 1;
        }

        ret = clock_get_time(aClock, &aTime);
        if (ret != KERN_SUCCESS) {
          return 2;
        }

        return 0;
      }
    " HAVE_CLOCK_GET_TIME)
  endif()

  if(HAVE_CLOCK_GET_TIME)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()
