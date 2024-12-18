#[=============================================================================[
# The apache2handler SAPI

Configure the `apache2handler` PHP SAPI.

## PHP_SAPI_APACHE2HANDLER

* Default: `OFF`
* Values: `ON|OFF`

Enable the shared Apache 2 handler SAPI module.

Loadable via Apache's Dynamic Shared Object (DSO) support. If Apache will use
PHP together with one of the threaded Multi-Processing Modules (MPMs), PHP must
be configured and built with `PHP_THREAD_SAFETY` set to `ON`. Thread safety will
be set automatically during the configuration step, if threaded Apache can be
discovered on the system.

Path where to look for the Apache installation on the system can be customized
with the `APACHE_ROOT` and `Apache_APXS_EXECUTABLE` variables.

For example:

```cmake
cmake -B php-build -DAPACHE2HANDLER=ON -DAPACHE_ROOT=/opt/apache2
# or
cmake -B php-build -DAPACHE2HANDLER=ON -DApache_EXECUTABLE=/opt/apache2/bin/apxs
```
#]=============================================================================]

include(FeatureSummary)

option(PHP_SAPI_APACHE2HANDLER "Enable the shared Apache 2 handler SAPI module")

add_feature_info(
  "sapi/apache2handler"
  PHP_SAPI_APACHE2HANDLER
  "Apache HTTP server module"
)

if(NOT PHP_SAPI_APACHE2HANDLER)
  return()
endif()

add_library(php_sapi_apache2handler SHARED)
add_library(PHP::sapi::apache2handler ALIAS php_sapi_apache2handler)

target_sources(
  php_sapi_apache2handler
  PRIVATE
    apache_config.c
    mod_php.c
    php_functions.c
    php_functions.stub.php
    sapi_apache2.c
)

set_target_properties(
  php_sapi_apache2handler
  PROPERTIES
    OUTPUT_NAME apache
)

target_compile_definitions(
  php_sapi_apache2handler
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

find_package(Apache 2.4.0)
set_package_properties(
  Apache
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the Apache PHP SAPI."
)

target_link_libraries(
  php_sapi_apache2handler
  PRIVATE
    PHP::sapi
    Apache::Apache
)

# Manually enable runtime linking on AIX.
if(CMAKE_SYSTEM_NAME STREQUAL "AIX" AND EXISTS ${Apache_LIBEXECDIR}/httpd.exp)
  include(CheckLinkerFlag)
  check_linker_flag(
    C
    "LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp"
    _PHP_HAVE_BRTL_FLAG_C
  )
  if(_PHP_HAVE_BRTL_FLAG_C)
    target_link_options(
      php_sapi_apache2handler
      PRIVATE
        "$<$<PLATFORM_ID:AIX>LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp>"
    )
  endif()
endif()

if(Apache_THREADED AND NOT PHP_THREAD_SAFETY)
  # Enable thread safety. Ideally, thread safety should be opt-in and such
  # automatic enabling isn't encouraged.
  set_property(CACHE PHP_THREAD_SAFETY PROPERTY VALUE TRUE)
  message(
    WARNING
    "Apache's current threaded MPM requires thread safety. "
    "PHP_THREAD_SAFETY has been automatically set to 'ON'."
  )
elseif(NOT Apache_THREADED AND NOT PHP_THREAD_SAFETY)
  # Run at the end of the configuration phase to notify that PHP needs thread
  # safety, when using Apache threaded MPM.
  cmake_language(
    DEFER
    DIRECTORY ${PHP_SOURCE_DIR}
    CALL php_sapi_apache2handler_notice
  )
  function(php_sapi_apache2handler_notice)
    cmake_language(DEFER CALL message NOTICE [[

      Notice:

      Apache 2 handler SAPI will be built with Apache's current
      non-threaded MPM. If you change Apache to use a threaded
      MPM, make sure PHP is configured and built with
      'PHP_THREAD_SAFETY' set to 'ON'.

    ]])
  endfunction()
endif()

install(
  TARGETS php_sapi_apache2handler
  DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
