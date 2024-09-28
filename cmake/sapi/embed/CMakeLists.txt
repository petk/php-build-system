include(FeatureSummary)

option(SAPI_EMBED "Enable the Embed SAPI module" OFF)

add_feature_info(
  "sapi/embed"
  SAPI_EMBED
  "Embed SAPI module"
)

message(CHECK_START "Checking embed SAPI")
if(SAPI_EMBED)
  message(CHECK_PASS "enabled")
else()
  message(CHECK_FAIL "disabled")
  return()
endif()

add_library(php_embed STATIC)
add_library(PHP::embed ALIAS php_embed)

target_sources(
  php_embed
  PRIVATE
    php_embed.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_embed.h
)

target_link_libraries(php_embed PRIVATE PHP::main)

target_compile_definitions(php_embed PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(
  php_embed
  PROPERTIES
    OUTPUT_NAME libphp
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
)

# Configure pkgconf php-embed.pc metadata file.
include(PHP/PkgConfigGenerator)
pkgconfig_generate_pc(
  php-embed.pc.in
  php-embed.pc
  TARGET php_embed
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    exec_prefix "$<INSTALL_PREFIX>"
    includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_INCLUDEDIR},$<INSTALL_PREFIX>>"
    php_include_prefix "${PHP_INCLUDE_PREFIX}"
    libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},$<INSTALL_PREFIX>>"
    PHP_VERSION "${PHP_VERSION}"
    PHP_VERSION_ID "${PHP_VERSION_ID}"
    PHP_EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_FULL_CONFIG_FILE_SCAN_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},$<INSTALL_PREFIX>>"
    PHP_DEBUG "$<IF:$<CONFIG:Debug,DebugAssertions>,yes,no>"
    PHP_THREAD_SAFETY "$<IF:$<BOOL:$<TARGET_PROPERTY:php_configuration,PHP_THREAD_SAFETY>>,yes,no>"
)

install(
  TARGETS php_embed
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
