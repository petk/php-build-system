include(CMakeDependentOption)

option(EXT_MYSQLND "Whether to enable the mysqlnd extension" OFF)

cmake_dependent_option(EXT_MYSQLND_SHARED "Whether to build the mysqlnd extension as shared object" OFF "EXT_MYSQLND;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_MYSQLND_COMPRESSION "Whether to enable compressed protocol support in mysqlnd" ON "EXT_MYSQLND" OFF)

if(NOT EXT_MYSQLND)
  return()
endif()

if(EXT_MYSQLND_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "mysqlnd" ${_library_type} PRIORITY 10)

add_library(ext_mysqlnd ${_library_type}
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

target_compile_definitions(ext_mysqlnd PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXT_MYSQLND_COMPRESSION)
  find_package(ZLIB REQUIRED)

  if(ZLIB_LIBRARIES)
    target_link_libraries(ext_mysqlnd PRIVATE ${ZLIB_LIBRARIES})
  endif()

  if(ZLIB_INCLUDE_DIRS)
    target_include_directories(ext_mysqlnd PRIVATE ${ZLIB_INCLUDE_DIRS})
  endif()

  set(MYSQLND_COMPRESSION_ENABLED 1 CACHE INTERNAL "Enable compressed protocol support")
endif()

set(MYSQLND_SSL_SUPPORTED 1 CACHE INTERNAL "Enable core mysqlnd SSL code")

if(EXT_OPENSSL)
  find_package(OpenSSL 1.0.2)

  # TODO: Can OpenSSL be retrieved differently (from one place) here?
  if(OPENSSL_FOUND)
    set(MYSQLND_HAVE_SSL 1 CACHE INTERNAL "Enable mysqlnd code that uses OpenSSL directly")

    if(OPENSSL_LIBRARIES)
      target_link_libraries(ext_mysqlnd PRIVATE ${OPENSSL_LIBRARIES})
    endif()

    if(OPENSSL_INCLUDE_DIRS)
      target_include_directories(ext_mysqlnd PRIVATE ${OPENSSL_INCLUDE_DIRS})
    endif()
  endif()
endif()

file(GLOB _ext_mysqlnd_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  ext_mysqlnd
  PUBLIC FILE_SET ext_mysqlnd_headers
  TYPE HEADERS
  FILES ${_ext_mysqlnd_headers}
)

install(
  TARGETS ext_mysqlnd
  FILE_SET ext_mysqlnd_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/mysqlnd
)
