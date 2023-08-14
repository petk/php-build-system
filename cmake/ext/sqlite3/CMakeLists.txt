option(sqlite3 "Whether to enable the sqlite3 extension" ON)

if(NOT sqlite3)
  return()
endif()
