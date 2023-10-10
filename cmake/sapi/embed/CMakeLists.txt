option(SAPI_EMBED "Whether to use the PHP Embed SAPI module" OFF)

if(NOT SAPI_EMBED)
  return()
endif()

add_library(php_embed
  php_embed.c
)

set_target_properties(php_embed PROPERTIES OUTPUT_NAME libphp)

target_link_libraries(php_embed PRIVATE php_main)

target_compile_definitions(php_embed PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(EXTRA_DEFINITIONS)
  target_compile_definitions(php_embed PRIVATE ${EXTRA_DEFINITIONS})
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php_embed PROPERTIES ENABLE_EXPORTS TRUE)

install(TARGETS php_embed DESTINATION ${CMAKE_INSTALL_LIBDIR})

target_sources(
  php_embed
  PUBLIC FILE_SET sapi_embed_headers
  TYPE HEADERS
  FILES php_embed.h
)

install(
  TARGETS php_embed
  FILE_SET sapi_embed_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/sapi/embed
)
