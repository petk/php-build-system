# TODO: this is a header only library and it doesn't need to be linked to other libraries.
# Only headers need to be included.
message(STATUS "Checking for POSIX threads")

add_library(php_tsrm STATIC TSRM.c)
add_library(PHP::TSRM ALIAS php_tsrm)

target_link_libraries(php_tsrm PRIVATE PHP::configuration)

target_include_directories(php_tsrm
  PRIVATE ${CMAKE_SOURCE_DIR}
          ${CMAKE_BINARY_DIR}
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(php_tsrm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

install(
  FILES
    tsrm_win32.h
    TSRM.h
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/TSRM
)
