include(CMakeDependentOption)

option(mysqlnd "Whether to enable the mysqlnd extension" OFF)

cmake_dependent_option(mysqlnd_compression "Whether to enable compressed protocol support in mysqlnd" ON "mysqlnd" OFF)

if(NOT mysqlnd)
  return()
endif()

string(TOLOWER ${mysqlnd} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME mysqlnd ${extension_library_type})

add_library(ext_mysqlnd ${extension_library_type}
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

file(GLOB MYSQLND_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
set_target_properties(ext_mysqlnd PROPERTIES PUBLIC_HEADER "${MYSQLND_HEADER_FILES}")

if(mysqlnd_compression)
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

if(openssl)
  find_package(OpenSSL 1.0.2)

  if(OPENSSL_FOUND)
    set(MYSQLND_HAVE_SSL 1 CACHE INTERNAL "Enable mysqlnd code that uses OpenSSL directly")
    target_link_libraries(ext_mysqlnd PRIVATE ${OPENSSL_LIBRARIES})
    target_include_directories(ext_mysqlnd PRIVATE ${OPENSSL_INCLUDE_DIRS})
  endif()
endif()
