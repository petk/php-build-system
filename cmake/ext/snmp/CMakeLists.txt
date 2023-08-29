include(CMakeDependentOption)

option(EXT_SNMP "Whether to enable the SNMP extension" OFF)

cmake_dependent_option(EXT_SNMP_SHARED "Whether to build the SNMP extension as shared object" OFF "EXT_SNMP;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SNMP)
  return()
endif()

if(EXT_SNMP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "snmp" ${_library_type})

#add_library(ext_snmp ${_library_type})
