option(calendar "Whether to enable the calendar extension" OFF)

if(calendar)
  project(ext_calendar VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "Calendar PHP extension")

  string(TOLOWER ${calendar} calendar_lower)
  set(calendar_library_type "STATIC")
  if(calendar_lower STREQUAL "shared")
    set(calendar_library_type "SHARED")
  endif()

  php_extension(NAME "calendar" ${calendar_library_type})

  add_library(ext_calendar ${calendar_library_type}
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
endif()
