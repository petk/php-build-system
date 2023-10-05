option(SAPI_APACHE2HANDLER "Whether to use the PHP Apache SAPI module" OFF)

if(NOT SAPI_APACHE2HANDLER)
  return()
endif()

#install(TARGETS apache DESTINATION ${CMAKE_INSTALL_LIBDIR})
