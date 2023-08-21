option(apache "Whether to use the PHP Apache SAPI module" OFF)

if(NOT apache)
  return()
endif()
