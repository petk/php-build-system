#[=============================================================================[
Check for clock_get*time().

Cache variables:

  HAVE_CLOCK_GETTIME
    Whether clock_gettime() is present.
  HAVE_CLOCK_GET_TIME
    Whether clock_get_time() is present.

Interface library:

  PHP::CheckClockGettime
    If there are additional libraries that need to be linked.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

php_search_libraries(
  clock_gettime
  "time.h"
  HAVE_CLOCK_GETTIME
  _php_clock_gettime_library
  LIBRARIES
    rt # Solaris 10
)
if(_php_clock_gettime_library)
  add_library(php_check_clock_gettime INTERFACE)
  add_library(PHP::CheckClockGettime ALIAS php_check_clock_gettime)

  target_link_libraries(php_check_clock_gettime INTERFACE ${_php_clock_gettime_library})
endif()

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
