#[=============================================================================[
# The embed SAPI

## Configuration options

### PHP_SAPI_EMBED

* Default: `OFF`
* Values: `ON|OFF`

Enables the embedded PHP SAPI module for embedding PHP into application using C
bindings.

The embed library is after the build phase located in the `sapi/embed`
directory:

* as a shared library `libphp.so` (\*nix), or `libphp.dylib` (macOS), or
  `phpembed.dll` (Windows)
* and a static library `libphp.a` (\*nix), or `phpembed.lib` (Windows)

which can be further used in other applications. It exposes PHP API as C library
for other programs to use PHP.
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

add_library(php_sapi_embed_shared SHARED)
add_library(PHP::sapi::embed_shared ALIAS php_sapi_embed_shared)

target_sources(
  php_sapi_embed
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_embed.h
)

foreach(target IN ITEMS php_sapi_embed php_sapi_embed_shared)
  target_sources(${target} PRIVATE php_embed.c)

  target_link_libraries(${target} PRIVATE $<BUILD_INTERFACE:PHP::core>)

  target_compile_definitions(${target} PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set_target_properties(
      ${target}
      PROPERTIES
        PREFIX ""
        OUTPUT_NAME ${PHP_PROGRAM_PREFIX}phpembed${PHP_PROGRAM_SUFFIX}
    )
  else()
    set_target_properties(
      ${target}
      PROPERTIES
        PREFIX lib
        OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}
    )
  endif()

  set_target_properties(
    ${target}
    PROPERTIES
      PHP_CLI TRUE
  )
endforeach()

set_target_properties(
  php_sapi_embed
  PROPERTIES
    EXPORT_NAME EmbedStatic
)

set_target_properties(
  php_sapi_embed_shared
  PROPERTIES
    EXPORT_NAME EmbedShared
)

# Configure pkg-config php-embed.pc metadata file.
include(PHP/PkgConfig)
php_pkgconfig_generate_pc(
  php-embed.pc.in
  php-embed.pc
  TARGET PHP::sapi::embed_shared
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    exec_prefix "$<INSTALL_PREFIX>"
    includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_INCLUDEDIR},$<INSTALL_PREFIX>>"
    php_include_prefix "${PHP_INCLUDE_PREFIX}"
    libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},$<INSTALL_PREFIX>>"
    PHP_VERSION "${PHP_VERSION}"
    PHP_VERSION_ID "${PHP_VERSION_ID}"
    PHP_EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_SCAN_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},$<INSTALL_PREFIX>>"
    PHP_DEBUG "$<IF:$<CONFIG:Debug,DebugAssertions>,yes,no>"
    PHP_THREAD_SAFETY "$<IF:$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>,yes,no>"
    PHP_EMBED_SAPI_NAME "$<GENEX_EVAL:$<TARGET_PROPERTY:php_sapi_embed_shared,OUTPUT_NAME>>"
    PHP_API_VERSION "${PHP_API_VERSION}"
    PHP_ZEND_EXTENSION_API_NO "$<TARGET_PROPERTY:PHP::Zend,PHP_ZEND_EXTENSION_API_NO>"
    PHP_ZEND_MODULE_API_NO "$<TARGET_PROPERTY:PHP::Zend,PHP_ZEND_MODULE_API_NO>"
)

install(
  TARGETS php_sapi_embed php_sapi_embed_shared
  EXPORT php_sapi_embed_export
  ARCHIVE
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT php-sapi-embed
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT php-sapi-embed
  LIBRARY
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT php-sapi-embed
  FILE_SET HEADERS
    DESTINATION ${PHP_INSTALL_INCLUDEDIR}/sapi/embed
    COMPONENT php-development
)

install(
  EXPORT php_sapi_embed_export
  NAMESPACE PHP::
  FILE PHPEmbedTargets.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP/targets
  COMPONENT php-development
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/php-embed.pc
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
  COMPONENT php-development
)

if(PHP_TESTING)
  add_subdirectory(tests)
endif()
