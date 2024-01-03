add_library(php_tsrm STATIC)

target_sources(php_tsrm PRIVATE
  $<$<PLATFORM_ID:Windows>:tsrm_win32.c>
  TSRM.c
)

add_library(PHP::TSRM ALIAS php_tsrm)

target_link_libraries(php_tsrm PRIVATE PHP::configuration)

target_include_directories(php_tsrm INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}")

target_compile_definitions(php_tsrm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_sources(
  php_tsrm
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      $<$<PLATFORM_ID:Windows>:tsrm_win32.h>
      TSRM.h
)

install(
  TARGETS php_tsrm
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
