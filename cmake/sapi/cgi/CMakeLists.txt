option(SAPI_CGI "Enable the CGI SAPI module" ON)

if(NOT SAPI_CGI)
  return()
endif()

add_executable(php_cgi
  cgi_main.c
)

set_target_properties(php_cgi PROPERTIES OUTPUT_NAME php-cgi)

target_compile_definitions(php_cgi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php_cgi PRIVATE PHP::main)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set_target_properties(php_cgi PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php_cgi PROPERTIES ENABLE_EXPORTS TRUE)

# Man documentation.
configure_file(php-cgi.1.in php-cgi.1 @ONLY)

install(
  TARGETS php_cgi
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(
  FILES
    php-cgi.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)
