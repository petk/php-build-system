#[=============================================================================[
# The calendar extension

Configure the `calendar` extension.

This extension provides support for calendar conversion.

## EXT_CALENDAR

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_CALENDAR_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionCalendar
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_CALENDAR "Enable the calendar extension" OFF)

add_feature_info(
  "ext/calendar"
  EXT_CALENDAR
  "Calendar conversion support"
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

target_sources(
  php_calendar
  PRIVATE
    cal_unix.c
    calendar.c
    calendar.stub.php
    dow.c
    easter.c
    french.c
    gregor.c
    jewish.c
    julian.c
)

set(HAVE_CALENDAR 1)

configure_file(config.cmake.h.in config.h)
