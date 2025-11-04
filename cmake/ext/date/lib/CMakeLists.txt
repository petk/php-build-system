#[=============================================================================[
# timelib

Simplified CMake-based build system for the timelib library.

## Configuration variables

* `TIMELIB_NAMESPACE`

  Namespace string used as the project name and variables prefix. If not
  specified, default value is `TIMELIB`.

  * `<TIMELIB_NAMESPACE>_VERSION`.

* `TIMELIB_TARGET`

  If specified, this target will be used to add timelib source files to it and
  compile properties. If not specified, a library target named `timelib` will be
  created.

## Examples

Adding timelib with `add_subdirectory()`:

```cmake
set(TIMELIB_NAMESPACE "PHP_EXT_DATE_TIMELIB")
set(TIMELIB_TARGET php_ext_date)
add_subdirectory(lib)
```
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

if(NOT TIMELIB_NAMESPACE)
  set(TIMELIB_NAMESPACE "TIMELIB")
endif()

# The timelib version.
block(PROPAGATE ${TIMELIB_NAMESPACE}_VERSION)
  file(
    STRINGS
    timelib.h
    _
    REGEX "^[ \t]*#[ \t]*define[ \t]+TIMELIB_ASCII_VERSION[ \t]+\"([0-9.]+[^\"]*)"
  )

  set(${TIMELIB_NAMESPACE}_VERSION "${CMAKE_MATCH_1}")

  message(STATUS "Configuring timelib ${${TIMELIB_NAMESPACE}_VERSION}")
endblock()

project(
  ${TIMELIB_NAMESPACE}
  VERSION ${${TIMELIB_NAMESPACE}_VERSION}
  #SPDX_LICENSE "MIT"
  DESCRIPTION "Timezone and date/time library"
  HOMEPAGE_URL "https://github.com/derickr/timelib"
  LANGUAGES C
)

include(CheckCompilerFlag)

if(NOT TIMELIB_TARGET)
  set(TIMELIB_TARGET timelib)
  add_library(${TIMELIB_TARGET})
endif()

set(
  timelib_sources
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
    ${timelib_sources}
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
    # timelib uses C99 strtoll() function conditionally.
    $<$<NOT:$<PLATFORM_ID:Windows>>:HAVE_STRTOLL>
    # timelib includes C99 <stdint.h> header conditionally.
    HAVE_STDINT_H
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
  OUTPUT_VARIABLE relative_dir
)
message(STATUS "Creating ${relative_dir}/timelib_config.h")
file(CONFIGURE OUTPUT timelib_config.h CONTENT [[
/* Define to 1 if you have the <io.h> header file. */
#cmakedefine HAVE_IO_H 1
]])
