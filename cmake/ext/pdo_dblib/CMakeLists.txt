option(pdo_dblib "Whether to enable the pdo_dblib extension" ON)

if(NOT pdo_dblib)
  return()
endif()
