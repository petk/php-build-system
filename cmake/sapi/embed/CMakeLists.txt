option(SAPI_EMBED "Whether to use the PHP Embed SAPI module" OFF)

if(NOT SAPI_EMBED)
  return()
endif()

add_library(embed
  php_embed.c
)

target_compile_definitions(embed PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

install(TARGETS embed DESTINATION ${CMAKE_INSTALL_LIBDIR})

target_sources(
  embed
  PUBLIC FILE_SET sapi_embed_headers
  TYPE HEADERS
  FILES php_embed.h
)

install(
  TARGETS embed
  FILE_SET sapi_embed_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/sapi/embed
)
