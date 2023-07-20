option(calendar "Whether to enable the calendar extension" OFF)

if(calendar)
  php_extension(NAME "calendar")

  add_library(ext_calendar
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
