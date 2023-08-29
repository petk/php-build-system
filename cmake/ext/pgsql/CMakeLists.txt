include(CMakeDependentOption)

option(EXT_PGSQL "Whether to enable the pgsql extension" OFF)

cmake_dependent_option(EXT_PGSQL_SHARED "Whether to build the pgsql extension as shared object" OFF "EXT_PGSQL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PGSQL)
  return()
endif()

if(EXT_PGSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pgsql" ${_library_type})

#add_library(ext_pgsql ${_library_type})
