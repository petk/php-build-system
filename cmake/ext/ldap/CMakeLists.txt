include(CMakeDependentOption)

option(EXT_LDAP "Whether to enable the ldap extension" OFF)

cmake_dependent_option(EXT_LDAP_SHARED "Whether to build the ldap extension as shared object" OFF "EXT_LDAP;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_LDAP)
  return()
endif()

if(EXT_LDAP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "ldap" ${_library_type})

#add_library(ext_ldap ${_library_type})
