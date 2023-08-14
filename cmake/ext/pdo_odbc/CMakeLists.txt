option(pdo_odbc "Whether to enable the pdo_odbc extension" ON)

if(NOT pdo_odbc)
  return()
endif()
