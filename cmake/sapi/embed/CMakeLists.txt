option(SAPI_EMBED "Enable the Embed SAPI module" OFF)

message(CHECK_START "Checking whether to build embed SAPI")
if(SAPI_EMBED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  return()
endif()

add_library(php_embed)
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
block()
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
  set(includedir "${CMAKE_INSTALL_FULL_INCLUDEDIR}")
  set(libdir "${CMAKE_INSTALL_FULL_LIBDIR}")
  configure_file(php-embed.pc.in php-embed.pc @ONLY)
endblock()

install(
  TARGETS php_embed
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/sapi/embed
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/php-embed.pc
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
