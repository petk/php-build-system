include(CMakeDependentOption)

option(EXT_READLINE "Whether to enable the readline extension" OFF)

cmake_dependent_option(EXT_READLINE_SHARED "Whether to build the readline extension as shared object" OFF "EXT_READLINE;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_READLINE)
  return()
endif()

if(EXT_READLINE_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME readline ${_library_type})

#add_library(ext_readline ${_library_type})
