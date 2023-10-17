include(CMakeDependentOption)

option(EXT_CALENDAR "Whether to enable the calendar extension" OFF)

cmake_dependent_option(
  EXT_CALENDAR_SHARED
  "Whether to build the calendar extension as shared object"
  OFF
  "EXT_CALENDAR;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_CALENDAR)
  return()
endif()

if(EXT_CALENDAR_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_calendar ${_library_type}
  calendar.c
  dow.c
  french.c
  gregor.c
  jewish.c
  julian.c
  easter.c
  cal_unix.c
)
