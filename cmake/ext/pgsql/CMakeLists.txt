option(pgsql "Whether to enable the pgsql extension" ON)

if(NOT pgsql)
  return()
endif()
