option(pdo_sqlite "Whether to enable the pdo_sqlite extension" ON)

if(NOT pdo_sqlite)
  return()
endif()
