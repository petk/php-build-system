option(SAPI_APACHE "Whether to use the PHP Apache SAPI module" OFF)

if(NOT SAPI_APACHE)
  return()
endif()

#install(TARGETS apache DESTINATION ${CMAKE_INSTALL_LIBDIR})
