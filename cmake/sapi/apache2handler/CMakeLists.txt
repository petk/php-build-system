include(FeatureSummary)

option(
  SAPI_APACHE2HANDLER
  "Enable the shared Apache 2 handler SAPI module

  Loadable via Apache's Dynamic Shared Object (DSO) support; If Apache will use\
  PHP with one of the threaded Multi-Processing Modules (MPMs), PHP must be\
  configured and built with PHP_THREAD_SAFETY set to 'ON'. Thread safety will\
  be set automatically during the configuration step, if threaded Apache can be\
  discovered on the system."
  OFF
)

add_feature_info(
  "sapi/apache2handler"
  SAPI_APACHE2HANDLER
  "Apache 2 handler SAPI module"
)

message(CHECK_START "Checking apache2handler SAPI")
if(SAPI_APACHE2HANDLER)
  message(CHECK_PASS "enabled")
else()
  message(CHECK_FAIL "disabled")
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

set_target_properties(
  php_apache2handler
  PROPERTIES
    OUTPUT_NAME apache
)

target_compile_definitions(
  php_apache2handler
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

find_package(Apache 2.4.0)
set_package_properties(
  Apache
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the Apache PHP SAPI."
)

if(Apache_THREADED)
  if(NOT PHP_THREAD_SAFETY)
    set_property(CACHE PHP_THREAD_SAFETY PROPERTY VALUE TRUE)
    message(
      WARNING
      "Apache's current threaded MPM requires thread safety. "
      "PHP_THREAD_SAFETY has been automatically set to 'ON'."
    )
  endif()

  add_feature_info(
    "sapi/apache2handler"
    SAPI_APACHE2HANDLER
    "Apache 2 handler SAPI with Apache's current threaded MPM"
  )
else()
  add_feature_info(
    "sapi/apache2handler"
    SAPI_APACHE2HANDLER
    "Apache 2 handler SAPI with Apache's current non-threaded MPM

    Notice: If you change Apache to use a threaded MPM, make sure
    PHP is configured and built with PHP_THREAD_SAFETY set to 'ON'.
  ")
endif()

target_link_libraries(
  php_apache2handler
  PRIVATE
    PHP::main
    Apache::Apache
)

install(
  TARGETS php_apache2handler
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Manually enable runtime linking on AIX.
if(CMAKE_SYSTEM_NAME STREQUAL "AIX" AND EXISTS ${Apache_LIBEXECDIR}/httpd.exp)
  include(CheckLinkerFlag)
  check_linker_flag(
    C
    "LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp"
    _HAVE_BRTL_FLAG_C
  )
  if(_HAVE_BRTL_FLAG_C)
    target_link_options(
      php_apache2handler
      PRIVATE
        "$<$<PLATFORM_ID:AIX>LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp>"
    )
  endif()
endif()
