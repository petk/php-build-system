# TODO: this is a header only library and it doesn't need to be linked to other libraries.
# Only headers need to be included.
message(STATUS "Checking for POSIX threads")

add_library(php_tsrm STATIC TSRM.c)

target_include_directories(php_tsrm
  PRIVATE ${CMAKE_SOURCE_DIR}
          ${CMAKE_BINARY_DIR}
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(php_tsrm PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

file(GLOB_RECURSE _tsrm_headers "${PROJECT_SOURCE_DIR}/TSRM/*.h")
install(FILES ${_tsrm_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/TSRM)
