#[=============================================================================[
Check for clock_get*time.
#]=============================================================================]

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/SearchLibraries)

php_search_libraries(
  clock_gettime
  HEADERS time.h
  LIBRARIES
    rt # Solaris 10
  VARIABLE PHP_SAPI_FPM_HAVE_CLOCK_GETTIME
  TARGET php_sapi_fpm PRIVATE
)
set(HAVE_CLOCK_GETTIME ${PHP_SAPI_FPM_HAVE_CLOCK_GETTIME})

# Checking for working clock_get_time() on macOS systems is obsolete as of macOS
# Sierra (10.12) where the clock_gettime() was added.
if(
  NOT PHP_SAPI_FPM_HAVE_CLOCK_GETTIME
  AND NOT DEFINED PHP_SAPI_FPM_HAVE_CLOCK_GET_TIME
)
  message(CHECK_START "Checking for clock_get_time()")

  # When crosscompiling, check only whether the test code builds and assume it
  # also runs.
  if(
    CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
    AND NOT DEFINED PHP_SAPI_FPM_HAVE_CLOCK_GET_TIME_EXITCODE
  )
    set(PHP_SAPI_FPM_HAVE_CLOCK_GET_TIME_EXITCODE 0)
  endif()

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_runs(C [[
      #include <mach/mach.h>
      #include <mach/clock.h>
      #include <mach/mach_error.h>

      int main(void)
      {
        kern_return_t ret;
        clock_serv_t aClock;
        mach_timespec_t aTime;

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
    ]] PHP_SAPI_FPM_HAVE_CLOCK_GET_TIME)
  cmake_pop_check_state()

  if(PHP_SAPI_FPM_HAVE_CLOCK_GET_TIME)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_CLOCK_GET_TIME "${PHP_SAPI_FPM_HAVE_CLOCK_GET_TIME}")
