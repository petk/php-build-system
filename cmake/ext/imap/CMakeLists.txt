# TODO: Extension is not configured.
return()

include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_IMAP "Enable the imap extension" OFF)

add_feature_info("ext/imap" EXT_IMAP
  "Support for operating with the IMAP protocol."
)

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
