include(CMakeDependentOption)

option(EXT_DBA "Whether to enable the DBA extension" OFF)

cmake_dependent_option(
  EXT_DBA_SHARED
  "Whether to build the DBA extension as shared object"
  OFF
  "EXT_DBA;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_DBA)
  return()
endif()

if(EXT_DBA_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "dba" ${_library_type})

#add_library(php_dba ${_library_type})
