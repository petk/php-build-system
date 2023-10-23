include(CMakeDependentOption)

option(EXT_IMAP "Enable the imap extension" OFF)

cmake_dependent_option(
  EXT_IMAP_SHARED
  "Build the imap extension as a shared library"
  OFF
  "EXT_IMAP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_IMAP)
  return()
endif()

if(EXT_IMAP_SHARED)
  add_library(php_imap SHARED)
else()
  add_library(php_imap)
endif()

#target_sources(php_imap PRIVATE
  #...
#)
