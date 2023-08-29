include(CMakeDependentOption)

cmake_dependent_option(EXT_PDO_MYSQL "Whether to enable the pdo_mysql extension" OFF "EXT_PDO" OFF)

cmake_dependent_option(EXT_PDO_MYSQL_SHARED "Whether to build the pdo_mysql extension as shared object" OFF "EXT_PDO_MYSQL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PDO_MYSQL)
  return()
endif()

if(EXT_PDO_MYSQL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "pdo_mysql" ${_library_type})

#add_library(ext_pdo_mysql ${_library_type})
