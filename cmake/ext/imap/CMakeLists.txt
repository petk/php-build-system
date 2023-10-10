include(CMakeDependentOption)

option(EXT_IMAP "Whether to enable the IMAP extension" OFF)

cmake_dependent_option(EXT_IMAP_SHARED "Whether to build the IMAP extension as shared object" OFF "EXT_IMAP;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_IMAP)
  return()
endif()

if(EXT_IMAP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

#php_extension(NAME "imap" ${_library_type})

#add_library(php_imap ${_library_type})
