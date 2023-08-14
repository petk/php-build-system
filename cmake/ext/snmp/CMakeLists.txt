option(snmp "Whether to enable the snmp extension" ON)

if(NOT snmp)
  return()
endif()
