#[=============================================================================[
# The embed SAPI

Configure the `embed` PHP SAPI.

## PHP_SAPI_EMBED

* Default: `OFF`
* Values: `ON|OFF`

Enable the embedded PHP SAPI module for embedding PHP into application using C
bindings.

The embed library is then located in the `sapi/embed` directory as a shared
library `libphp.so`, or a static library `libphp.a`, which can be further used
in other applications. It exposes PHP API as C library object for other programs
to use PHP.
#]=============================================================================]

include(FeatureSummary)

option(PHP_SAPI_EMBED "Enable the Embed SAPI module")

add_feature_info(
  "sapi/embed"
  PHP_SAPI_EMBED
  "module for embedding PHP into application"
)

if(NOT PHP_SAPI_EMBED)
  return()
endif()

add_library(php_sapi_embed STATIC)
add_library(PHP::sapi::embed ALIAS php_sapi_embed)

target_sources(
  php_sapi_embed
  PRIVATE
    php_embed.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_embed.h
)

target_link_libraries(
  php_sapi_embed
  PRIVATE
    PHP::sapi
)

target_compile_definitions(php_sapi_embed PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

set_target_properties(
  php_sapi_embed
  PROPERTIES
    OUTPUT_NAME libphp
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
    PHP_CLI TRUE
)

# Configure pkg-config php-embed.pc metadata file.
include(PHP/PkgConfigGenerator)
pkgconfig_generate_pc(
  php-embed.pc.in
  php-embed.pc
  TARGET PHP::sapi::embed
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    exec_prefix "$<INSTALL_PREFIX>"
    includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_INCLUDEDIR},$<INSTALL_PREFIX>>"
    php_include_prefix "${PHP_INCLUDE_PREFIX}"
    libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},$<INSTALL_PREFIX>>"
    PHP_VERSION "${PHP_VERSION}"
    PHP_VERSION_ID "${PHP_VERSION_ID}"
    PHP_EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},$<INSTALL_PREFIX>>"
    # TODO: Fix this for cmake --install ... --prefix
    PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_SCAN_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},$<INSTALL_PREFIX>>"
    PHP_DEBUG "$<IF:$<CONFIG:Debug,DebugAssertions>,yes,no>"
    PHP_THREAD_SAFETY "$<IF:$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>,yes,no>"
)

install(
  TARGETS php_sapi_embed
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/sapi/embed
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/php-embed.pc
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
