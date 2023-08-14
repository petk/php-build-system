option(calendar "Whether to enable the calendar extension" OFF)

if(NOT calendar)
  return()
endif()

project(ext_calendar VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "Calendar PHP extension")

string(TOLOWER ${calendar} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "calendar" ${extension_library_type})

add_library(ext_calendar ${extension_library_type}
  calendar.c
  dow.c
  french.c
  gregor.c
  jewish.c
  julian.c
  easter.c
  cal_unix.c
)

target_include_directories(
  ext_calendar
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
)
