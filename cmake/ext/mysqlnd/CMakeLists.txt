include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_MYSQLND "Enable the mysqlnd extension" OFF)

add_feature_info(
  "ext/mysqlnd"
  EXT_MYSQLND
  "MySQL Native Driver for supporting MySQL-compatible database in extensions."
)

cmake_dependent_option(
  EXT_MYSQLND_SHARED
  "Build the mysqlnd extension as a shared library"
  OFF
  "EXT_MYSQLND;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_MYSQLND_COMPRESSION
  "Enable compressed protocol support in mysqlnd"
  ON
  "EXT_MYSQLND"
  OFF
)

add_feature_info(
  "ext/mysqlnd compression"
  EXT_MYSQLND_COMPRESSION
  "MySQL compressed protocol support in the mysqlnd extension."
)

# TODO: Check if a single option should set ext/ftp and ext/mysqlnd. Sync this
# with Autoconf's --with-openssl-dir option.
cmake_dependent_option(
  EXT_MYSQLND_SSL
  "Explicitly enable SSL support for ext/mysqlnd when not using ext/openssl"
  OFF
  "EXT_MYSQLND"
  OFF
)

if(EXT_MYSQLND_SSL OR EXT_OPENSSL)
  set(_ext_mysqlnd_ssl TRUE)
else()
  set(_ext_mysqlnd_ssl FALSE)
endif()

add_feature_info(
  "ext/mysqlnd SSL"
  ${_ext_mysqlnd_ssl}
  "SSL support in the mysqlnd extension."
)

if(NOT EXT_MYSQLND)
  return()
endif()

if(EXT_MYSQLND_SHARED)
  add_library(php_mysqlnd SHARED)
else()
  add_library(php_mysqlnd)
endif()

file(GLOB _php_mysqlnd_headers ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
# Exclude Windows header and specify it below separately.
list(FILTER _php_mysqlnd_headers EXCLUDE REGEX ".*config-win\\.h$")

target_sources(
  php_mysqlnd
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
        ${_php_mysqlnd_headers}
        $<$<PLATFORM_ID:Windows>:config-win.h>
)

target_compile_definitions(php_mysqlnd PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQLND_COMPRESSION)
  find_package(ZLIB)
  set_package_properties(
    ZLIB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable compression in the mysqlnd extension."
  )

  target_link_libraries(php_mysqlnd PRIVATE ZLIB::ZLIB)

  set(
    MYSQLND_COMPRESSION_ENABLED 1
    CACHE INTERNAL "Enable compressed protocol support"
  )
endif()

set(MYSQLND_SSL_SUPPORTED 1 CACHE INTERNAL "Enable core mysqlnd SSL code")

if(EXT_MYSQLND_SSL OR EXT_OPENSSL)
  find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
  set_package_properties(
    OpenSSL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable SSL in the mysqlnd extension."
  )

  target_link_libraries(php_mysqlnd PRIVATE OpenSSL::Crypto)

  set(
    MYSQLND_HAVE_SSL 1
    CACHE INTERNAL "Enable mysqlnd code that uses OpenSSL directly"
  )
endif()
