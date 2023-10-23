include(CMakeDependentOption)

option(EXT_ODBC "Enable the odbc extension" OFF)

cmake_dependent_option(
  EXT_ODBC_SHARED
  "Build the odbc extension as a shared library"
  OFF
  "EXT_ODBC;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ODBC)
  return()
endif()

if(EXT_ODBC_SHARED)
  add_library(php_odbc SHARED)
else()
  add_library(php_odbc)
endif()

#target_sources(php_odbc PRIVATE
  #...
#)
