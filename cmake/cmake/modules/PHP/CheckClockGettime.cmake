#[=============================================================================[
Check for clock_get*time().

Cache variables:

  HAVE_CLOCK_GETTIME
    Whether clock_gettime() is present.
  HAVE_CLOCK_GET_TIME
    Whether clock_get_time() is present.

IMPORTED target:

  PHP::CheckClockGettimeLibrary
    If there is additional library to be linked for using clock_gettime().
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

php_search_libraries(
  clock_gettime
  HAVE_CLOCK_GETTIME
  HEADERS time.h
  LIBRARIES
    rt # Solaris 10
  LIBRARY_VARIABLE libraryForClockGettime
)
if(libraryForClockGettime)
  add_library(PHP::CheckClockGettimeLibrary INTERFACE IMPORTED)
  target_link_libraries(
    PHP::CheckClockGettimeLibrary
    INTERFACE
      ${libraryForClockGettime}
  )
endif()

if(HAVE_CLOCK_GETTIME)
  return()
endif()

message(CHECK_START "Checking for clock_get_time")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_runs(C [[
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
  ]] HAVE_CLOCK_GET_TIME)
cmake_pop_check_state()

if(HAVE_CLOCK_GET_TIME)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
