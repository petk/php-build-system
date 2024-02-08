include(CheckStructHasMember)

option(SAPI_CGI "Enable the CGI SAPI module" ON)

message(CHECK_START "Checking whether to build cgi SAPI")
if(SAPI_CGI)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  return()
endif()

add_executable(php_cgi
  cgi_main.c
)

target_compile_definitions(php_cgi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(
  php_cgi
  PRIVATE
    PHP::main
    $<$<PLATFORM_ID:Windows>:ws2_32;kernel32;advapi32>
)

target_link_options(
  php_cgi
  PRIVATE
    $<$<PLATFORM_ID:Windows>:/stack:67108864>
)

set_target_properties(
  php_cgi
  PROPERTIES
    OUTPUT_NAME php-cgi
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
)

# BSD systems.
check_struct_has_member("struct sockaddr_un" sun_len sys/un.h HAVE_SOCKADDR_UN_SUN_LEN)

message(CHECK_START "Checking whether accept() requires cross-process locking")
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  set(USE_LOCKING 1 CACHE INTERNAL "Whether accept() requires cross-process locking")
endif()
if(USE_LOCKING)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Man documentation.
configure_file(php-cgi.1.in php-cgi.1 @ONLY)

install(
  TARGETS php_cgi
  RUNTIME
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/php-cgi.1"
  DESTINATION "${CMAKE_INSTALL_MANDIR}/man1"
)
