#[=============================================================================[
# The cgi SAPI

Configure the `cgi` PHP SAPI.

## PHP_SAPI_CGI

* Default: `ON`
* Values: `ON|OFF`

Enable the PHP CGI (Common Gateway Interface) SAPI executable module.
#]=============================================================================]

include(CheckStructHasMember)
include(FeatureSummary)

option(PHP_SAPI_CGI "Enable the CGI (Common Gateway Interface) SAPI" ON)

add_feature_info(
  "sapi/cgi"
  PHP_SAPI_CGI
  "Common Gateway Interface executable"
)

if(NOT PHP_SAPI_CGI)
  return()
endif()

add_executable(php_sapi_cgi)
add_executable(PHP::sapi::cgi ALIAS php_sapi_cgi)

target_sources(
  php_sapi_cgi
  PRIVATE
    cgi_main.c
    cgi_main.stub.php
)

target_compile_definitions(php_sapi_cgi PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_link_libraries(
  php_sapi_cgi
  PRIVATE
    $<BUILD_INTERFACE:PHP::sapi>
    $<$<PLATFORM_ID:Windows>:ws2_32;kernel32;advapi32>
)

if(MSVC)
  target_link_options(php_sapi_cgi PRIVATE /stack:67108864)
endif()

set_target_properties(
  php_sapi_cgi
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php-cgi${PHP_PROGRAM_SUFFIX}
    ENABLE_EXPORTS TRUE # TODO: Check if there's a better solution.
    PHP_CLI TRUE
    PHP_SAPI_FASTCGI TRUE
)

# BSD systems.
check_struct_has_member(
  "struct sockaddr_un"
  sun_len
  sys/un.h
  HAVE_SOCKADDR_UN_SUN_LEN
)

message(CHECK_START "Checking whether accept() requires cross-process locking")
if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  set(USE_LOCKING TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

install(
  TARGETS php_sapi_cgi
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

################################################################################
# Configure man documentation.
################################################################################

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  configure_file(php-cgi.1.in php-cgi.1 @ONLY)
  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/php-cgi.1
    RENAME ${PHP_PROGRAM_PREFIX}php-cgi${PHP_PROGRAM_SUFFIX}.1
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
  )
endif()

################################################################################
# Configuration header.
################################################################################

configure_file(cmake/config.h.in config.h)
