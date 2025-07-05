#[=============================================================================[
# The apache2handler SAPI

## Configuration options

### PHP_SAPI_APACHE2HANDLER

* Default: `OFF`
* Values: `ON|OFF`

Enables the shared Apache 2 handler SAPI module.

### PHP_SAPI_APACHE2HANDLER_INSTALL_DIR

* Default: The path to the Apache modules directory of the host system
  (`Apache_LIBEXEC`).

The path where to install the PHP Apache module (`mod_php.so`). Relative path is
interpreted as being relative to the installation prefix `CMAKE_INSTALL_PREFIX`.

## About

Loadable via Apache's Dynamic Shared Object (DSO) support. If Apache will use
PHP together with one of the threaded Multi-Processing Modules (MPMs), PHP must
be configured and built with `PHP_THREAD_SAFETY` set to `ON`. Thread safety will
be set automatically during the configuration step, if threaded Apache can be
discovered on the system.

Path where to look for the Apache installation on the system can be customized
with the `APACHE_ROOT` and `Apache_APXS_EXECUTABLE` variables.

For example:

```sh
cmake -B php-build -DPHP_SAPI_APACHE2HANDLER=ON -DAPACHE_ROOT=/opt/apache2
# or
cmake -B php-build -DPHP_SAPI_APACHE2HANDLER=ON -DApache_EXECUTABLE=/opt/apache2/bin/apxs
```

The path, where to install the PHP Apache module, can be overridden with the
`PHP_SAPI_APACHE2HANDLER_INSTALL_DIR` variable. This might be used in edge cases
where some specific custom installation prefix is used to avoid insufficient
permissions of the default location on the host, or when developing the PHP
build system.

```sh
cmake \
  -B <build-dir> \
  -DPHP_SAPI_APACHE2HANDLER=ON \
  -DPHP_SAPI_APACHE2HANDLER_INSTALL_DIR=/custom/path/to/lib/apache2/modules
```
#]=============================================================================]

include(FeatureSummary)

option(PHP_SAPI_APACHE2HANDLER "Enable the shared Apache 2 handler SAPI module")

add_feature_info(
  "sapi/apache2handler"
  PHP_SAPI_APACHE2HANDLER
  "Apache HTTP server module"
)

set(
  CACHE{PHP_SAPI_APACHE2HANDLER_INSTALL_DIR}
  TYPE STRING
  HELP "The path to the Apache modules directory to install PHP Apache module"
  VALUE ""
)
mark_as_advanced(PHP_SAPI_APACHE2HANDLER_INSTALL_DIR)

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
    EXPORT_NAME Apache2Handler
    OUTPUT_NAME mod_${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}
)

target_compile_definitions(
  php_sapi_apache2handler
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

find_package(Apache 2.0.44)
set_package_properties(
  Apache
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the Apache PHP SAPI."
)

if(Apache_FOUND AND NOT PHP_SAPI_APACHE2HANDLER_INSTALL_DIR)
  set_property(
    CACHE PHP_SAPI_APACHE2HANDLER_INSTALL_DIR
    PROPERTY VALUE "${Apache_LIBEXECDIR}"
  )
endif()

target_link_libraries(
  php_sapi_apache2handler
  PRIVATE
    $<BUILD_INTERFACE:PHP::core>
    Apache::Apache
)

# Manually enable runtime linking on AIX.
if(CMAKE_SYSTEM_NAME STREQUAL "AIX" AND EXISTS ${Apache_LIBEXECDIR}/httpd.exp)
  include(CheckLinkerFlag)
  check_linker_flag(
    C
    "LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp"
    PHP_HAS_BRTL_FLAG_C
  )
  if(PHP_HAS_BRTL_FLAG_C)
    target_link_options(
      php_sapi_apache2handler
      PRIVATE
        "$<$<LINKER_LANGUAGE:C>:LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp>"
    )
  endif()

  check_linker_flag(
    CXX
    "LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp"
    PHP_HAS_BRTL_FLAG_CXX
  )
  if(PHP_HAS_BRTL_FLAG_CXX)
    target_link_options(
      php_sapi_apache2handler
      PRIVATE
        "$<$<LINKER_LANGUAGE:CXX>:LINKER:-brtl;LINKER:-bI${Apache_LIBEXECDIR}/httpd.exp>"
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
  LIBRARY
    DESTINATION ${PHP_SAPI_APACHE2HANDLER_INSTALL_DIR}
    COMPONENT php-sapi-apache2handler
  RUNTIME
    DESTINATION ${PHP_SAPI_APACHE2HANDLER_INSTALL_DIR}
    COMPONENT php-sapi-apache2handler
)
