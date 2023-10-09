include(CMakeDependentOption)

option(EXT_MYSQLND "Whether to enable the mysqlnd extension" OFF)

cmake_dependent_option(EXT_MYSQLND_SHARED "Whether to build the mysqlnd extension as shared object" OFF "EXT_MYSQLND;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_MYSQLND_COMPRESSION "Whether to enable compressed protocol support in mysqlnd" ON "EXT_MYSQLND" OFF)

# TODO: Check if a single option should set ext/ftp and ext/mysqlnd. Sync this
# with Autoconf's --with-openssl-dir option.
cmake_dependent_option(EXT_MYSQLND_SSL "Whether to explicitly enable SSL support for ext/mysqlnd when not using ext/openssl" OFF "EXT_MYSQLND" OFF)

if(NOT EXT_MYSQLND)
  return()
endif()

if(EXT_MYSQLND_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "mysqlnd" ${_library_type} PRIORITY 10)

add_library(mysqlnd ${_library_type}
  mysqlnd_connection.c
  mysqlnd_alloc.c
  mysqlnd_charset.c
  mysqlnd_wireprotocol.c
  mysqlnd_loaddata.c
  mysqlnd_reverse_api.c
  mysqlnd_vio.c
  mysqlnd_protocol_frame_codec.c
  mysqlnd_statistics.c
  mysqlnd_driver.c
  mysqlnd_ext_plugin.c
  mysqlnd_auth.c
  mysqlnd_result.c
  mysqlnd_result_meta.c
  mysqlnd_debug.c
  mysqlnd_commands.c
  mysqlnd_block_alloc.c
  mysqlnd_read_buffer.c
  mysqlnd_plugin.c
  php_mysqlnd.c
  mysqlnd_ps.c
  mysqlnd_ps_codec.c
)

target_compile_definitions(mysqlnd PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQLND_COMPRESSION)
  find_package(ZLIB REQUIRED)

  if(TARGET ZLIB::ZLIB)
    target_link_libraries(mysqlnd PRIVATE ZLIB::ZLIB)
  endif()

  set(MYSQLND_COMPRESSION_ENABLED 1 CACHE INTERNAL "Enable compressed protocol support")
endif()

set(MYSQLND_SSL_SUPPORTED 1 CACHE INTERNAL "Enable core mysqlnd SSL code")

if(EXT_MYSQLND_SSL OR EXT_OPENSSL)
  # TODO: Can OpenSSL be retrieved differently (from one place) here?
  find_package(OpenSSL 1.0.2 REQUIRED)

  if(TARGET OpenSSL::Crypto)
    target_link_libraries(mysqlnd PRIVATE OpenSSL::Crypto)
  endif()

  set(MYSQLND_HAVE_SSL 1 CACHE INTERNAL "Enable mysqlnd code that uses OpenSSL directly")
endif()

file(GLOB _mysqlnd_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  mysqlnd
  PUBLIC FILE_SET mysqlnd_headers
  TYPE HEADERS
  FILES ${_mysqlnd_headers_files}
)

install(
  TARGETS mysqlnd
  FILE_SET mysqlnd_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/mysqlnd
)
