#[=============================================================================[
Check for clock_get*time().

Cache variables:

  HAVE_CLOCK_GETTIME
    Whether clock_gettime() is present.
  HAVE_CLOCK_GET_TIME
    Whether clock_get_time() is present.

IMPORTED target:

  PHP::CheckClockGettimeLibrary
    If there are additional libraries that need to be linked.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

block()
  php_search_libraries(
    clock_gettime
    "time.h"
    HAVE_CLOCK_GETTIME
    clock_gettime_library
    LIBRARIES
      rt # Solaris 10
  )

  if(clock_gettime_library)
    add_library(PHP::CheckClockGettimeLibrary INTERFACE IMPORTED)

    target_link_libraries(
      PHP::CheckClockGettimeLibrary
      INTERFACE
        ${clock_gettime_library}
    )
  endif()
endblock()

if(NOT HAVE_CLOCK_GETTIME)
  message(CHECK_START "Checking for clock_get_time")

  if(NOT CMAKE_CROSSCOMPILING)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

      check_source_runs(C "
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
    cmake_pop_check_state()
  endif()

  if(HAVE_CLOCK_GET_TIME)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()
