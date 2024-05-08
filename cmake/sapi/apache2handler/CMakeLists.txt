include(FeatureSummary)

option(
  SAPI_APACHE2HANDLER
  "Enable the Apache SAPI (shared Apache 2 handler module via DSO)"
  OFF
)

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

set_target_properties(
  php_apache2handler
  PROPERTIES
    OUTPUT_NAME apache
)

find_package(Apache 2.0.44)
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
