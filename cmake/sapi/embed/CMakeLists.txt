option(SAPI_EMBED "Enable the Embed SAPI module" OFF)

if(NOT SAPI_EMBED)
  return()
endif()

add_library(php_embed
  php_embed.c
)

set_target_properties(php_embed PROPERTIES OUTPUT_NAME libphp)

target_link_libraries(php_embed PRIVATE PHP::main)

target_compile_definitions(php_embed PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# TODO: Check if there's a better solution here.
set_target_properties(php_embed PROPERTIES ENABLE_EXPORTS TRUE)

target_sources(
  php_embed
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      php_embed.h
)

install(
  TARGETS php_embed
  RUNTIME
    DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY
    DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  FILE_SET HEADERS
)
