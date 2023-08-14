option(pdo_mysql "Whether to enable the pdo_mysql extension" ON)

if(NOT pdo_mysql)
  return()
endif()
