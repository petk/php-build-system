option(SAPI_APACHE2HANDLER "Enable the Apache SAPI module" OFF)

if(NOT SAPI_APACHE2HANDLER)
  return()
endif()

#add_library(php_apache2handler STATIC)
#set_target_properties(php_apache2handler PROPERTIES OUTPUT_NAME apache)
#install(TARGETS php_apache2handler DESTINATION "${CMAKE_INSTALL_LIBDIR}")
#target_link_libraries(php_apache2hanlder PRIVATE PHP::main)
