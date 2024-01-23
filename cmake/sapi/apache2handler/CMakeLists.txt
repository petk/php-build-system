option(SAPI_APACHE2HANDLER "Enable the Apache SAPI module" OFF)

message(CHECK_START "Checking whether to build apache2handler SAPI")
if(SAPI_APACHE2HANDLER)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  return()
endif()

add_library(php_apache2handler SHARED)

target_sources(
  php_apache2handler
  PRIVATE
    apache_config.c
    mod_php.c
    php_functions.c
    sapi_apache2.c
)

target_link_libraries(php_apache2hanlder PRIVATE PHP::main)

set_target_properties(
  php_apache2handler
  PROPERTIES
    OUTPUT_NAME apache
)

install(
  TARGETS php_apache2handler
  DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)
