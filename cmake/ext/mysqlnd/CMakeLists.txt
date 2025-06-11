#[=============================================================================[
# The mysqlnd extension

Configure the `mysqlnd` extension.

This extension contains MySQL Native Driver for using MySQL-compatible databases
in PHP extensions.

## PHP_EXT_MYSQLND

* Default: `OFF`
* Values: `ON|OFF`

Enable the PHP `mysqlnd` extension.

## PHP_EXT_MYSQLND_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared library.

## PHP_EXT_MYSQLND_COMPRESSION

* Default: `ON`
* Values: `ON|OFF`

Enable compressed protocol support in mysqlnd.

## PHP_EXT_MYSQLND_SSL

* Default: `ON`
* Values: `ON|OFF`

Explicitly enable or disable extended SSL support in the `mysqlnd` extension. On
\*nix systems, the extended SSL works through the OpenSSL library and on Windows
through the Windows Crypt32 library.

For example, `mysqlnd` extension with disabled extended SSL support, would
require in MySQL Server 8.0 and later versions to have the
`default_authentication_plugin` configuration set to `mysql_native_password` in
`my.cnf` (`caching_sha2_password` therefore wouldn't be supported).

This option is only provided to explicitly avoid requiring the OpenSSL
dependency, otherwise recommended setting is `ON`.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionMysqlnd
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_MYSQLND "Enable the mysqlnd extension")

add_feature_info(
  "ext/mysqlnd"
  PHP_EXT_MYSQLND
  "MySQL-compatible databases native driver"
)

cmake_dependent_option(
  PHP_EXT_MYSQLND_SHARED
  "Build the mysqlnd extension as a shared library"
  OFF
  "PHP_EXT_MYSQLND;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  PHP_EXT_MYSQLND_COMPRESSION
  "Enable compressed protocol support in mysqlnd"
  ON
  "PHP_EXT_MYSQLND"
  OFF
)

add_feature_info(
  "ext/mysqlnd compression"
  PHP_EXT_MYSQLND_COMPRESSION
  "MySQL compressed protocol support"
)

cmake_dependent_option(
  PHP_EXT_MYSQLND_SSL
  "Explicitly enable extended SSL support in the mysqlnd extension through\
  OpenSSL system library (*nix) or Crypt32 (Windows)."
  ON
  "PHP_EXT_MYSQLND"
  OFF
)

if(NOT PHP_EXT_MYSQLND)
  return()
endif()

if(PHP_EXT_MYSQLND_SHARED)
  add_library(php_ext_mysqlnd SHARED)
else()
  add_library(php_ext_mysqlnd)
endif()

target_sources(
  php_ext_mysqlnd
  PRIVATE
    mysqlnd_alloc.c
    mysqlnd_auth.c
    mysqlnd_block_alloc.c
    mysqlnd_charset.c
    mysqlnd_commands.c
    mysqlnd_connection.c
    mysqlnd_debug.c
    mysqlnd_driver.c
    mysqlnd_ext_plugin.c
    mysqlnd_loaddata.c
    mysqlnd_plugin.c
    mysqlnd_protocol_frame_codec.c
    mysqlnd_ps_codec.c
    mysqlnd_ps.c
    mysqlnd_read_buffer.c
    mysqlnd_result_meta.c
    mysqlnd_result.c
    mysqlnd_reverse_api.c
    mysqlnd_statistics.c
    mysqlnd_vio.c
    mysqlnd_wireprotocol.c
    php_mysqlnd.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/config-win.h>
        mysql_float_to_double.h
        mysqlnd_alloc.h
        mysqlnd_auth.h
        mysqlnd_block_alloc.h
        mysqlnd_charset.h
        mysqlnd_commands.h
        mysqlnd_connection.h
        mysqlnd_debug.h
        mysqlnd_enum_n_def.h
        mysqlnd_ext_plugin.h
        mysqlnd_libmysql_compat.h
        mysqlnd_plugin.h
        mysqlnd_portability.h
        mysqlnd_priv.h
        mysqlnd_protocol_frame_codec.h
        mysqlnd_ps.h
        mysqlnd_read_buffer.h
        mysqlnd_result_meta.h
        mysqlnd_result.h
        mysqlnd_reverse_api.h
        mysqlnd_statistics.h
        mysqlnd_structs.h
        mysqlnd_vio.h
        mysqlnd_wireprotocol.h
        mysqlnd.h
        php_mysqlnd.h
)

target_compile_definitions(php_ext_mysqlnd PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_link_libraries(
  php_ext_mysqlnd
  PRIVATE
    $<$<PLATFORM_ID:Windows>:ws2_32>
)

if(PHP_EXT_MYSQLND_COMPRESSION)
  find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})
  set_package_properties(
    ZLIB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable compression in the mysqlnd extension."
  )

  target_link_libraries(php_ext_mysqlnd PRIVATE ZLIB::ZLIB)

  set(MYSQLND_COMPRESSION_ENABLED TRUE)
endif()

set(MYSQLND_SSL_SUPPORTED TRUE)

if(PHP_EXT_MYSQLND_SSL)
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_link_libraries(php_ext_mysqlnd PRIVATE crypt32)
  else()
    find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
    set_package_properties(
      OpenSSL
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable extended SSL in the mysqlnd extension."
    )
    target_link_libraries(php_ext_mysqlnd PRIVATE OpenSSL::Crypto)
  endif()

  set(MYSQLND_HAVE_SSL TRUE)

  add_dependencies(php_ext_mysqlnd php_ext_hash)
endif()

add_feature_info(
  "ext/mysqlnd SSL"
  MYSQLND_HAVE_SSL
  "extended SSL support through a system library"
)

configure_file(cmake/config.h.in config.h)
