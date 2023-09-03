option(SAPI_EMBED "Whether to use the PHP Embed SAPI module" OFF)

if(NOT SAPI_EMBED)
  return()
endif()

add_library(embed
  php_embed.c
)

target_compile_definitions(embed PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(embed PROPERTIES PUBLIC_HEADER "php_embed.h")
