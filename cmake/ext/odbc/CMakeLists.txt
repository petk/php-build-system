include(CMakeDependentOption)

option(EXT_ODBC "Whether to enable the ODBC extension" OFF)

cmake_dependent_option(
  EXT_ODBC_SHARED
  "Whether to build the ODBC extension as shared object"
  OFF
  "EXT_ODBC;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ODBC)
  return()
endif()

if(EXT_ODBC_SHARED)
  set(_type "SHARED")
endif()

#add_library(php_odbc ${_type})
