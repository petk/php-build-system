include(CMakeDependentOption)

option(EXT_MYSQLI "Whether to enable the mysqli extension" OFF)

cmake_dependent_option(EXT_MYSQLI_SHARED "Whether to build the mysqli extension as shared object" OFF "EXT_MYSQLI;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_MYSQLI)
  return()
endif()

if(EXT_MYSQLI_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "mysqli" ${_library_type})

#add_library(ext_mbstring ${_library_type})
