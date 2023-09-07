option(SAPI_CGI "Whether to enable building CGI version of PHP" ON)

if(NOT SAPI_CGI)
  return()
endif()

add_executable(php-cgi
  cgi_main.c
)

target_compile_definitions(php-cgi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php-cgi PUBLIC main)
target_link_libraries(php-cgi PUBLIC TSRM)
target_link_libraries(php-cgi PUBLIC Zend)

foreach(item IN LISTS PHP_EXTENSIONS)
  message(STATUS "Linking ${item}")
  target_link_libraries(php-cgi PUBLIC ext_${item})
endforeach()

if(EXTRA_LIBS)
  target_link_libraries(php-cgi PUBLIC ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(php-cgi PUBLIC ${EXTRA_DEFINITIONS})
endif()

# Man documentation.
configure_file(php-cgi.1.in php-cgi.1 @ONLY)

install(TARGETS php-cgi DESTINATION ${CMAKE_INSTALL_BINDIR})

install(
  FILES
    php-cgi.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)
