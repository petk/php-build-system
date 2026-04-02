#[=============================================================================[
# The calendar extension

This extension provides support for calendar conversion.

## Configuration options

### PHP_EXT_CALENDAR

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_CALENDAR
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_CALENDAR "Enable the calendar extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/calendar"
  PHP_EXT_CALENDAR
  "calendar conversion support"
)

if(NOT PHP_EXT_CALENDAR)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(calendar)

if(PHP_EXT_CALENDAR STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
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

target_include_directories(
  php_ext_calendar
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}
)

set(HAVE_CALENDAR TRUE)

configure_file(cmake/config.h.in config.h)
