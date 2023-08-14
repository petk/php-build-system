option(pdo_firebird "Whether to enable the pdo_firebird extension" ON)

if(NOT pdo_firebird)
  return()
endif()
