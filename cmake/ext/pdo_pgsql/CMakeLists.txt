option(pdo_pgsql "Whether to enable the pdo_pgsql extension" ON)

if(NOT pdo_pgsql)
  return()
endif()
