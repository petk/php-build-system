#[=============================================================================[
Check for clock_gettime().

Cache variables:

  HAVE_CLOCK_GETTIME
    Whether clock_gettime() is present.

  FPM_CLOCK_LIBRARIES
    A list of libraries for linking.

  HAVE_CLOCK_GET_TIME
    Whether clock_get_time() should be used.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CMakePushCheckState)

check_c_source_compiles("
  #include <time.h>

  int main(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return 0;
  }
" HAVE_CLOCK_GETTIME)

if(NOT HAVE_CLOCK_GETTIME)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES rt)
    check_c_source_compiles("
      #include <time.h>

      int main(void) {
        struct timespec ts;
        clock_gettime(CLOCK_MONOTONIC, &ts);
        return 0;
      }
    " HAVE_CLOCK_GETTIME)
  cmake_pop_check_state()

  if(HAVE_CLOCK_GETTIME)
    set(FPM_CLOCK_LIBRARIES rt CACHE INTERNAL "A list of required libraries for using clock_gettime().")
  endif()
endif()

if(NOT HAVE_CLOCK_GETTIME)
  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      #include <mach/mach.h>
      #include <mach/clock.h>
      #include <mach/mach_error.h>

      int main(void)
      {
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
endif()
