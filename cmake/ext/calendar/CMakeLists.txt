#[=============================================================================[
# The calendar extension

Configure the `calendar` extension.

This extension provides support for calendar conversion.

## PHP_EXT_CALENDAR

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_CALENDAR_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PhpExtensionCalendar
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_CALENDAR "Enable the calendar extension")

add_feature_info(
  "ext/calendar"
  PHP_EXT_CALENDAR
  "calendar conversion support"
)

cmake_dependent_option(
  PHP_EXT_CALENDAR_SHARED
  "Build the calendar extension as a shared library"
  OFF
  PHP_EXT_CALENDAR
  OFF
)

if(NOT PHP_EXT_CALENDAR)
  return()
endif()

if(PHP_EXT_CALENDAR_SHARED)
  add_library(php_ext_calendar MODULE)
else()
  add_library(php_ext_calendar OBJECT)
endif()

target_sources(
  php_ext_calendar
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

set(HAVE_CALENDAR TRUE)

configure_file(cmake/config.h.in config.h)
