include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_CALENDAR "Enable the calendar extension" OFF)

add_feature_info("ext/calendar" EXT_CALENDAR
  "Adds the calendar functions to PHP."
)

cmake_dependent_option(
  EXT_CALENDAR_SHARED
  "Build the calendar extension as a shared library"
  OFF
  "EXT_CALENDAR;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_CALENDAR)
  return()
endif()

if(EXT_CALENDAR_SHARED)
  add_library(php_calendar SHARED)
else()
  add_library(php_calendar)
endif()

target_sources(php_calendar PRIVATE
  cal_unix.c
  calendar.c
  dow.c
  easter.c
  french.c
  gregor.c
  jewish.c
  julian.c
)
