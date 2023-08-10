#[=============================================================================[
Checks whether the strptime() declaration fails.

The module sets the following variables:

``HAVE_STRPTIME_DECL_FAILS``
  Set to 1 if strptime() declaration fails.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CMakePushCheckState)

message(STATUS "Checking whether strptime() declaration fails")

cmake_push_check_state()
  if(HAVE_STRPTIME)
    set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -DHAVE_STRPTIME")
  endif()
  check_c_source_compiles("
  #include <time.h>

  int main(void) {
    #ifndef HAVE_STRPTIME
    # error no strptime() on this platform
    #else
    /* use invalid strptime() declaration to see if it fails to compile */
    int strptime(const char *s, const char *format, struct tm *tm);
    #endif
  }
  " strptime_decl)
cmake_pop_check_state()

if(NOT strptime_decl)
  message(STATUS "yes")
  set(HAVE_STRPTIME_DECL_FAILS 1 CACHE INTERNAL "whether strptime() declaration fails")
else()
  message(STATUS "no")
endif()

unset(strptime_decl)
