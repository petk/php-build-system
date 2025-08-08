#[=============================================================================[
# timelib

Simplified CMake-based build system for the timelib library.

## Usage

Adding timelib with `add_subdirectory()`:

```cmake
set(TIMELIB_TARGET php_ext_date)
add_subdirectory(lib)
```
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

# The timelib version.
block(PROPAGATE timelib_VERSION)
  file(
    STRINGS
    timelib.h
    _
    REGEX "^[ \t]*#[ \t]*define[ \t]+TIMELIB_ASCII_VERSION[ \t]+\"([0-9.]+[^\"]*)"
  )

  set(timelib_VERSION "${CMAKE_MATCH_1}")

  message(STATUS "Configuring timelib ${timelib_VERSION}")
endblock()

project(
  timelib
  LANGUAGES C
  VERSION ${timelib_VERSION}
)

include(CheckCompilerFlag)

if(NOT TIMELIB_TARGET)
  set(TIMELIB_TARGET timelib)
  add_library(${TIMELIB_TARGET})
endif()

set(
  timelibSources
    astro.c
    dow.c
    interval.c
    parse_date.c
    parse_iso_intervals.c
    parse_posix.c
    parse_tz.c
    timelib.c
    tm2unixtime.c
    unixtime2tm.c
)

target_sources(
  ${TIMELIB_TARGET}
  PRIVATE
    ${timelibSources}
  PUBLIC
    FILE_SET HEADERS
      FILES
        timelib.h
  PUBLIC
    FILE_SET generated
      TYPE HEADERS
      BASE_DIRS $<TARGET_PROPERTY:${TIMELIB_TARGET},BINARY_DIR>
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/timelib_config.h
)

target_include_directories(${TIMELIB_TARGET} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  ${TIMELIB_TARGET}
  PRIVATE
    HAVE_TIMELIB_CONFIG_H
    # The timelib uses C99 strtoll() function conditionally.
    HAVE_STRTOLL
)

check_compiler_flag(C -fwrapv PHP_EXT_DATE_HAS_FWRAP)
if(PHP_EXT_DATE_HAS_FWRAP)
  set_source_files_properties(
    ${timelibSources}
    TARGET_DIRECTORY ${TIMELIB_TARGET}
    PROPERTIES COMPILE_OPTIONS -fwrapv
  )
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_IO_H TRUE)
endif()

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_BINARY_DIR
  BASE_DIRECTORY ${CMAKE_BINARY_DIR}
  OUTPUT_VARIABLE relativeDir
)
message(STATUS "Creating ${relativeDir}/timelib_config.h")
file(CONFIGURE OUTPUT timelib_config.h CONTENT [[
/* Define to 1 if you have the <io.h> header file. */
#cmakedefine HAVE_IO_H 1
]])
