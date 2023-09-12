option(SAPI_CGI "Whether to enable building CGI version of PHP" ON)

if(NOT SAPI_CGI)
  return()
endif()

add_executable(php-cgi
  cgi_main.c
)

target_compile_definitions(php-cgi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php-cgi PRIVATE main)

if(EXTRA_LIBS)
  target_link_libraries(php-cgi PRIVATE ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(php-cgi PRIVATE ${EXTRA_DEFINITIONS})
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php-cgi PROPERTIES ENABLE_EXPORTS TRUE)

# Man documentation.
configure_file(php-cgi.1.in php-cgi.1 @ONLY)

install(TARGETS php-cgi DESTINATION ${CMAKE_INSTALL_BINDIR})

install(
  FILES
    php-cgi.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)
