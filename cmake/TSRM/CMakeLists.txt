add_library(php_tsrm OBJECT)
add_library(PHP::TSRM ALIAS php_tsrm)

target_sources(
  php_tsrm
  PRIVATE
    $<$<PLATFORM_ID:Windows>:tsrm_win32.c>
    TSRM.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        $<$<PLATFORM_ID:Windows>:tsrm_win32.h>
        TSRM.h
)

target_link_libraries(php_tsrm PRIVATE PHP::configuration)

target_include_directories(php_tsrm INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

target_compile_definitions(
  php_tsrm
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:TSRM_EXPORTS>
  INTERFACE
    # Pass transitively only to Zend::Zend library on Windows.
    $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:NAME>,zend>,$<PLATFORM_ID:Windows>>:TSRM_EXPORTS>
)

install(
  TARGETS php_tsrm
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/TSRM
)
