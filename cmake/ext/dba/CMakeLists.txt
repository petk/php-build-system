include(CMakeDependentOption)

option(EXT_DBA "Enable the dba extension" OFF)

cmake_dependent_option(
  EXT_DBA_SHARED
  "Build the dba extension as a shared library"
  OFF
  "EXT_DBA;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_DBA)
  return()
endif()

if(EXT_DBA_SHARED)
  add_library(php_dba SHARED)
else()
  add_library(php_dba)
endif()

#target_sources(php_dba PRIVATE
  #...
#)
